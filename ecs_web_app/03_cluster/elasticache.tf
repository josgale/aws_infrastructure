resource "aws_elasticache_subnet_group" "default" {
  name       = var.env_name
  subnet_ids = aws_subnet.app_public.*.id
}

resource "aws_elasticache_cluster" "default" {
  cluster_id           = var.env_name
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.x"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.default.name
  security_group_ids   = [aws_security_group.open_internal_communication.id]
}
