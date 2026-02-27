provider "aws" {
    region = "us-east-1"
}

module "eks" {
    source = "./modules/eks"
    env = "dev"
    desired_size = 2
    max_size = 2
    min_size = 1
    project = "cbz"
}
