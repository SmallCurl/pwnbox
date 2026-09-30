locals {
  teams        = [for i in range(1, var.team_count + 1) : format("%s%02d", var.team_prefix, i)]
  player_slots = range(1, var.players_per_team + 1)
  player_keys = toset(flatten([
    for team in local.teams : [
      for n in local.player_slots : "${team}-player${n}"
    ]
  ]))
}

resource "random_password" "player" {
  for_each = local.player_keys
  length   = 20
  special  = false
}

resource "hcloud_ssh_key" "deployer" {
  name       = "${var.team_prefix}-pwnbox-deployer"
  public_key = var.ssh_public_key
}

resource "hcloud_firewall" "pwnbox" {
  name = "${var.team_prefix}-pwnbox"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "3389"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_server" "pwnbox" {
  for_each     = toset(local.teams)
  name         = "${each.key}-pwnbox"
  server_type  = var.server_type
  image        = var.image
  location     = var.location
  ssh_keys     = [hcloud_ssh_key.deployer.id]
  firewall_ids = [hcloud_firewall.pwnbox.id]

  labels = {
    role = "gctf-pwnbox"
    team = each.key
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    team_name    = each.key
    player_count = var.players_per_team
    pwnbox_image = var.pwnbox_image
    passwords = [
      for n in local.player_slots : random_password.player["${each.key}-player${n}"].result
    ]
  })
}
