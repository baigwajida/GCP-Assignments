#!/bin/bash

echo "Creating SQL instance"
gcloud sql instances create wajida-pe-sql --tier=db-f1-micro --region=us-central1

echo "Creating Database"
gcloud sql databases create employee_mgmt --instance=wajida-pe-sql

echo "Creating user"
gcloud sql users create application_user --instance=wajida-pe-sql

echo "getting IP"
ip=`gcloud sql instances describe sql-instance-wajida --format="value(ipAddresses.ipAddress)"`

gcloud sql connect shell-instance16 << EOF

USE employee_mgmt;

CREATE TABLE employee_details (name VARCHAR(10), role VARCHAR(10));

INSERT INTO employee_details VALUES ('Wajida', 'PE');
INSERT INTO employee_details VALUES ('Varun', 'PE');
INSERT INTO employee_details VALUES ('Ashwini', 'PE');
INSERT INTO employee_details VALUES ('Darshit', 'PE');
INSERT INTO employee_details VALUES ('Utsav', 'PE');
INSERT INTO employee_details VALUES ('Chaitanya', 'DE');

SELECT * FROM employee_details;
UPDATE employee_details SET role='PE' WHERE name=='Chaitanya';
SELECT * FROM employee_details;
DELETE FROM employee_details WHERE name=='Utsav';
SELECT * FROM employee_details;

GRANT SELECT, INSERT on employee_mgmt.employee_details to application_user;
SHOW GRANTS application_user;

REVOKE SELECT, INSERT on employee_mgmt.employee_details from application_user;
SHOW GRANTS application_user;
EOF