resource "aws_instance" "name" {
    ami = "ami-002192a70217ac181"
    instance_type = "t2.micro"
    count = length(var.tags)
    tags = {
        Name = var.tags[count.index]
    }
  
}


# count follows the array type scenario ex. apple, banana, grape they are in order 0,1,2. 
# if we want to delete the banana, it will delete 2 i.e., grape and change banana to grape
# thats it is not a good approach