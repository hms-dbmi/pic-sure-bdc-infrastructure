
data "template_file" "route53-ip-vars" {
  template = file("route53-variables.template")
  vars = {
    pic-sure-mysql-address            = aws_db_instance.pic-sure-mysql.address
    wildfly-ec2-private_ip            = aws_instance.wildfly-ec2.private_ip
    httpd-ec2-private_ip              = aws_instance.httpd-ec2.private_ip
    hpds-ec2-private_ip               = aws_instance.hpds-ec2.private_ip
  }
}

resource "local_file" "route53-ip-vars-file" {
    content     = data.template_file.route53-ip-vars.rendered
    filename = "ip-vars.properties"
}