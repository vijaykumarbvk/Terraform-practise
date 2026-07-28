# locals {
#   subnet_ids = [
#     aws_subnet.subnet1.id,
#     aws_subnet.subnet2.id,
#     aws_subnet.subnet3.id
#   ]
# }

# resource "aws_route_table_association" "private" {
#   count = length(local.subnet_ids)

#   subnet_id      = local.subnet_ids[count.index]
#   route_table_id = aws_route_table.private.id
# }

#coount recommanded no consistency at the time of delation use for_each


locals {
  subnet_ids = [
    aws_subnet.subnet1.id,
    aws_subnet.subnet2.id,
    aws_subnet.subnet3.id
  ]
}

resource "aws_route_table_association" "private" {
  for_each = toset(local.subnet_ids)

  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}