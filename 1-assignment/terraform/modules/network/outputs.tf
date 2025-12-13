output "subnets" {
  description = "Structured list of subnets with CIDR and ID"
  value = {
    private = [
      for s in aws_subnet.private :
      {
        cidr = s.cidr_block
        id   = s.id
      }
    ]
    public = [
      for s in aws_subnet.public :
      {
        cidr = s.cidr_block
        id   = s.id
      }
    ]
  }
}

output "vpc" {
  value = {
    cidr = aws_vpc.this.cidr_block
    id   = aws_vpc.this.id
  }
}