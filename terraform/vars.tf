variable "esxi_host" {
    default = "192.168.1.200"
}

variable "esxi_username" {
    default = "root"
}

variable "esxi_password" {
    default = "PASSWORD"
}

variable "datastore" {
   default = "alldisks" 
}

variable "vswitch" {
    default = "vSwitch0"
}

variable "home_network" {
    default = "VM Network"
}