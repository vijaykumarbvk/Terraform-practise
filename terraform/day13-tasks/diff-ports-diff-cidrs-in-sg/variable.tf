# # variable.tf
# variable "cidr_port_map" {
#   type = map(list(number))
#   default = {
#     "0.0.0.0/0"      = [80, 443, 8080]      
#     "10.0.0.0/8"     = [22,3000, 8081, 8082]   
#     "192.168.0.0/16" = [9000]               
# }