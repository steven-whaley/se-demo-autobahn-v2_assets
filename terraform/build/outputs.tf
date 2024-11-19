output "webapp_url" {
    description = "The URL where you can reach the web app"
    value = "http://${aws_lb.webapp_lb.dns_name}"
}
