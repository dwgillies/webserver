# the web container's stdout/stderr, shipped by Docker's awslogs driver;
# the driver reaches CloudWatch Logs through the NAT, so with enable_nat =
# false new log lines are dropped (docker logs on the instance still works)
resource "aws_cloudwatch_log_group" "web" {
  name              = "/${var.name}/web"
  retention_in_days = var.log_retention_days
}

resource "aws_iam_role_policy" "web_logs" {
  name = "${var.name}-web-logs"
  role = aws_iam_role.instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "${aws_cloudwatch_log_group.web.arn}:*"
    }]
  })
}
