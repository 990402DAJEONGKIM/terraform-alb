provider "aws" {
    region ="ap-south-2" # 이거 기재되어도 aws cli 환경설정값이 우선됨

    # 기본 태그 설정
    default_tags{
        tags = {
        Project = "std4-terraform-practice"
        Owner = "std4"
        Class = "msp"
        ManageBy = "Terraform"
        }
    }   
}

 