
data "template_file" "route53-ip-vars" {
  template = file("route53-variables.template")
  vars = {
   genomic-etl-private_ip         = aws_instance.genomic-etl-ec2.private_ip
  }
}

resource "local_file" "route53-ip-vars-file" {
    content = data.template_file.route53-ip-vars.rendered
    filename = "ip-vars.properties"
}
