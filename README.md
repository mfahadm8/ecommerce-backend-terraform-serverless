# E-commerce Backend

This project is an example of a traditional e-commerce website backend built on AWS infrastructure using serverless architecture. It demonstrates the use of various AWS services, including Amazon API Gateway, AWS Lambda, Amazon Cognito, Amazon RDS (PostgreSQL), AWS Secrets Manager, and Amazon SQS.

## Project Structure

The project follows a modular structure, separating the infrastructure code from the business logic code. Here's a breakdown of the folder structure:


- `infra/`: Contains the Terraform configuration files for provisioning the AWS resources.
  - `main.tf`: Defines the overall infrastructure configuration.
  - `variables.tf`: Contains the input variables used in the Terraform modules.
  - `outputs.tf`: Specifies the output values from the Terraform modules.
  - `modules/`: Contains individual modules for provisioning specific AWS resources.

- `src/`: Contains the business logic code for each Lambda function.
  - Each Lambda function has its own subfolder with a `main.py` file containing the Python code.

## AWS Services Used

The project utilizes several AWS services to build a secure and scalable backend:

- **Amazon API Gateway**: Provides a RESTful API interface for the e-commerce website, including endpoints for creating orders and retrieving customer orders.

- **AWS Lambda**: Implements the business logic for various functions, including creating orders, retrieving customer orders, and processing orders.

- **Amazon Cognito**: Handles user authentication and authorization, ensuring secure access to the backend APIs.

- **Amazon RDS (PostgreSQL)**: Stores the data for the `Orders` and `ProductInfo` tables.

- **AWS Secrets Manager**: Manages the credentials for accessing the PostgreSQL database, ensuring secure storage and rotation.

- **Amazon SQS**: Acts as a message queue for handling order processing. The `CreateOrderFunction` sends messages to SQS Queue 1, which triggers the `ProcessOrderFunction`. The `ProcessOrderFunction` updates the `ProductInfo` table and sends messages to SQS Queue 2, which triggers the `UpdateStocksFunction`.

## Getting Started

To set up the project:

1. Clone the repository and navigate to the `infra/` directory.
2. Modify the `variables.tf` file to specify your desired configuration values.
3. Run `terraform init` to initialize the Terraform project.
4. Run `terraform apply` to provision the AWS resources.
5. After the resources are provisioned, navigate to the `src/` directory.
6. Modify the `main.py` files for each Lambda function to implement your desired business logic.
7. Deploy the Lambda functions using the AWS CLI or other deployment methods.
8. Test the backend APIs using the provided endpoints.

For detailed instructions on configuring and running the project, refer to the documentation in the respective folders and files.

## Conclusion

This e-commerce backend project showcases the use of AWS services and serverless architecture to build a scalable and secure backend infrastructure. By following the provided folder structure and instructions, you can set up and customize the project according to your specific e-commerce application requirements.

Feel free to explore the code and adapt it to your needs. Contributions and feedback are welcome!
