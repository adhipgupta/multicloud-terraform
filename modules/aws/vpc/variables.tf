// Copyright (c) 2020 Arista Networks, Inc.
// Use of this source code is governed by the Apache License 2.0
// that can be found in the LICENSE file.
variable "subnet_zones" {
  description = "Subnet to Availability Zone map"
  type        = map(string)
}
variable "subnet_names" {
  description = "Subnet to name map"
  type        = map(string)
}
variable "region" {
  default = ""
}
variable "cidr" {
  description = "VPC Cidr"
}
variable "tags" {
  default = {}
}
variable "ami" {
  description = "AMI for the VM"
}
variable "public_key" {
  description = "Public key material to create keyPair"
}

