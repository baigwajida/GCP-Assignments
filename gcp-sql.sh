#!/bin/bash

echo "Creating SQL instance"
gcloud sql instances create wajida-sql-instance --tier=db-f1-micro --region=us-central1 --authorized-networks=59.152.52.0/22

echo "Creating Database"
gcloud sql databases create employee_mgmt --instance=wajida-sql-intance

echo "Creating user"
gcloud sql users create application_user --instance=wajida-sql-instance

echo "getting IP"

gcloud sql instances describe wajida-sql-instance --format=json > sql_inst.json
ip=$(python instance_sql.py)


gcloud sql users list --instance=wajida-sql-instance

gcloud sql connect wajida-sql-instance --user=root << EOF


USE employee_mgmt;

CREATE TABLE employee_details (name VARCHAR(10), role VARCHAR(10));

INSERT INTO employee_details VALUES ('Wajida', 'PE');
INSERT INTO employee_details VALUES ('Varun', 'PE');
INSERT INTO employee_details VALUES ('Ashwini', 'PE');
INSERT INTO employee_details VALUES ('Darshit', 'PE');
INSERT INTO employee_details VALUES ('Utsav', 'PE');
INSERT INTO employee_details VALUES ('Chaitanya', 'DE');

SELECT * FROM employee_details;
UPDATE employee_details SET role='PE' WHERE name='Chaitanya';
SELECT * FROM employee_details;
DELETE FROM employee_details WHERE name='Utsav';
SELECT * FROM employee_details;

GRANT SELECT, INSERT on employee_mgmt.employee_details to application_user;
SHOW GRANTS application_user;

REVOKE SELECT, INSERT on employee_mgmt.employee_details from application_user;
SHOW GRANTS application_user;

RENAME TABLE employee_details to employee_info;
SELECT * FROM employee_info;
DROP TABLE employee_info;

EOF
