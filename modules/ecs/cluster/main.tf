resource "aws_ecs_cluster" "this" {
  name = var.app_id

  tags = {
    Name = var.app_id
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}
