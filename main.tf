resource "google_compute_network" "vpc" {
  name                    = "novatech-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  description             = "NovaTech Foundation custom VPC"
}

resource "google_compute_subnetwork" "public" {
  name                     = "novatech-public-subnet"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = "10.10.1.0/24"
  private_ip_google_access = true
  description              = "Public subnet for web-facing resources"
}

resource "google_compute_subnetwork" "private" {
  name                     = "novatech-private-subnet"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = "10.10.2.0/24"
  private_ip_google_access = true
  description              = "private subnet for databases and internal services"
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "novatech-allow-ssh"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-enabled"]
}

resource "google_compute_firewall" "allow_http" {
  name    = "novatech-allow-http"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-servers"]
}

resource "google_compute_firewall" "allow_https" {
  name    = "novatech-allow-https"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-servers"]
}

resource "google_compute_firewall" "allow_internal" {
  name    = "novatec-allow-internal"
  network = google_compute_network.vpc.name
  allow {
    protocol = "all"
  }
  source_ranges = ["10.10.0.0/16"]
}

resource "google_storage_bucket" "assets" {
  name                        = "${var.project_id}-assets"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  lifecycle_rule {
    condition { age = 30 }
    action { type = "Delete" }
  }

  labels = {
    environment = var.environment
    project     = "novatech"
    managed_by  = "terraform"

  }
}

resource "google_compute_address" "web_ip" {
  name         = "novatech-web-ip"
  region       = var.region
  network_tier = "PREMIUM"
  description  = "Static IP for NovaTech web server"
}

resource "google_compute_instance" "web" {
  name         = "novatech-web-01"
  machine_type = "e2-medium"
  zone         = var.zone
  tags         = ["web-servers", "ssh-enabled"]
  description  = "NovaTech web server running Nginx"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public.id
    access_config {
      nat_ip = google_compute_address.web_ip.address
    }
  }

  metadata_startup_script = <<-SCRIPT
#!/bin/bash
apt-get update -y && apt-get install -y nginx
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html><html><head><title>NovaTech</title>
<style>body{font-family:sans-serif;display:flex;justify-content:center;
align-items:center;min-height:100vh;background:#f0f4f9;margin:0}
.card{background:#fff;padding:40px 60px;border-radius:12px;
box-shadow:0 2px 12px rgba(0,0,0,0.1);text-align:center}
h1{color:#4285F4}p{color:#5f6368;font-size:18px}
.tag{color:#9aa0a6;font-size:14px;margin-top:16px}
</style></head><body><div class="card">
<h1>NovaTech Foundation</h1>
<p>Project 01 — Built with Terraform</p>
<p class="tag">Infrastructure as Code</p>
</div></body></html>
EOF
systemctl start nginx && systemctl enable nginx
SCRIPT

  labels = {
    environment = var.environment
    project     = "novatech"
    managed_by  = "terraform"
  }
}






