data "template_file" "route53-ip-vars" {
  template = file("route53-variables.template")
  vars = {
    pic-sure-mysql-address            = aws_db_instance.pic-sure-mysql.address
    wildfly-ec2-private_ip            = aws_instance.wildfly-ec2.private_ip
    httpd-ec2-private_ip              = aws_instance.httpd-ec2.private_ip
    open-hpds-ec2-private_ip          = aws_instance.open-hpds-ec2.private_ip
    auth-hpds-ec2-private_ip          = aws_instance.auth-hpds-ec2.private_ip
  }
}

resource "local_file" "route53-ip-vars-file" {
    content  = data.template_file.route53-ip-vars.rendered
    filename = "ip-vars.properties"
}
