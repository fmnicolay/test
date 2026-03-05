output "env_id" {
  value       = local.env_id
  description = "Generated environment id (name + suffix)."
}

output "out_dir" {
  value       = local.out_dir
  description = "Output directory where files were generated."
}

output "service_files" {
  value       = { for k, f in local_file.service_files : k => f.filename }
  description = "Generated per-service file paths."
}
