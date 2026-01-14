output "jenkins_sg_id" {
  value = aws_security_group.jenkins.id
}

output "liberty_sg_id" {
  value = aws_security_group.liberty.id
}

output "monitoring_sg_id" {
  value = aws_security_group.monitoring.id
}
