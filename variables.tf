variable "token" {
	description	= "Linode API token"
	type 		= string
	sensitive	= true
}

variable "authorized_keys" {
	description	= "Public SSH key"
	type		= string
}

variable "root_pass" {
	description	= "Root password for the instance"
	type		= string
	sensitive	= true
}

variable "region" {
	description 	= "Linode region"
	type	 	= string
	default		= "us-east"
}

