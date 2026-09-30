output "addresses" {
  description = "Team name to public IPv4."
  value = {
    for name, srv in hcloud_server.pwnbox : name => srv.ipv4_address
  }
}

output "teams" {
  description = "RDP and SSH endpoints plus player passwords."
  sensitive   = true
  value = {
    for name, srv in hcloud_server.pwnbox : name => {
      ipv4 = srv.ipv4_address
      rdp  = "${srv.ipv4_address}:3389"
      ssh  = "ssh root@${srv.ipv4_address}"
      players = {
        for n in local.player_slots :
        "player${n}" => random_password.player["${name}-player${n}"].result
      }
    }
  }
}
