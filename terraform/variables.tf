variable "token" {
	description	= "Your Linode API Token"
	type 		= string
	sensitive	= true
}

variable "authorized_keys" {
	description	= "Your Public SSH key for the instance"
	type		= string
}

variable "root_pass" {
	description	= "The root password for the instance"
	type		= string
	sensitive	= true
}

variable "region" {
	description 	= "Linode region"
	type	 	= string
	default		= "us-east"
}

