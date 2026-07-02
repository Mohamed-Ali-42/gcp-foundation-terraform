output "vpc_name" {
  value = google_compute_network.vpc.name
}
output "public_subnet" {
  value = google_compute_subnetwork.public.ip_cidr_range
}
output "private_subnet" {
  value = google_compute_subnetwork.private.ip_cidr_range
}
output "bucket_url" {
  value = google_storage_bucket.assets.url
}
output "vm_name" {
  value = google_compute_instance.web.name
}
output "web_url" {
  description = "URL to access the Nginx web server"
  value       = "http://${google_compute_address.web_ip.address}"
}

