output "public_ip" {
    description = "Public Ip Of EC2"
    value = aws_instance.strapi.public_ip
}

output "strapi_url" {
    description = "URL For Strapi"
    value = "http://${aws_instance.strapi.public_ip}:1337"
}