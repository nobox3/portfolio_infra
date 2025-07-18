output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr" {
  value = aws_vpc.this.cidr_block
}

output "subnet" {
  value = {
    public  = aws_subnet.public
    private = aws_subnet.private
  }
}

output "db_subnet_group_id" {
  value = aws_db_subnet_group.this.id
}

output "elasticache_subnet_group_id" {
  value = aws_elasticache_subnet_group.this.id
}

output "security_group_ids" {
  value = {
    web   = aws_security_group.web.id
    vpc   = aws_security_group.vpc.id
    db    = aws_security_group.db.id
    cache = aws_security_group.cache.id
  }
}
