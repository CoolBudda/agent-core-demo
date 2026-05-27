## Architecture and services recommendations

##Frontend recommendation
- Vite
- React
- style sheet: Tailwind-only
- Linter: ESLint


## Backend recommendation
- Computation: AWS Lambda
- Language: Python 3.10+
- Linter: ruff
- Formatter: ruff format
- package and environment manager: uv


## Other services
- AWS api gateway receives user request and sends to integrated Lambda function
- AWS BedRock agent receives request from lambda and send to LLM for paln, ressoning etc.
- AWS BedRocke Agent  proesses bedrock agent calls
- Agent tool: a lambda to send email for conformation if information is complete

## Infrastructure
- using Terraform
