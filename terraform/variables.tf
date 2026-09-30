variable "ssh_public_key" {
  type        = string
  description = "SSH public key used to log in as root."
}

variable "team_count" {
  type        = number
  description = "How many team servers to create. One Hetzner VPS per team."

  validation {
    condition     = var.team_count >= 1 && var.team_count <= 50
    error_message = "team_count must be between 1 and 50."
  }
}

variable "team_prefix" {
  type        = string
  default     = "team"
  description = "Server names are <prefix>01, <prefix>02, ..."

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,20}$", var.team_prefix))
    error_message = "team_prefix must be a short lowercase hostname label."
  }
}

variable "players_per_team" {
  type        = number
  default     = 3
  description = "Desktop logins created on each server (player1 ...)."

  validation {
    condition     = var.players_per_team >= 1 && var.players_per_team <= 20
    error_message = "players_per_team must be between 1 and 20."
  }
}

variable "location" {
  type        = string
  default     = "fsn1"
  description = "Hetzner location: fsn1, nbg1, hel1, ash, sin, ..."
}

variable "server_type" {
  type        = string
  default     = "cx52"
  description = "32 GB class. Use cx53 or cpx51 if cx52 is unavailable."
}

variable "image" {
  type    = string
  default = "ubuntu-24.04"
}

variable "pwnbox_image" {
  type        = string
  default     = "changemeor/gctf-pwnbox:v2"
  description = "Docker image started on every team server."
}
