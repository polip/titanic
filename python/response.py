import json
import requests
from google.oauth2 import service_account
import pandas as pd
from beautifulsoup4 import BeautifulSoup


# Load your Titanic data as a pandas DataFrame
# titanic_df = pd.read_csv('your_titanic_data.csv')  # Example
# For demonstration, let's assume titanic_df is already defined

# Authenticate using the service account key
SERVICE_ACCOUNT_FILE = 'titanic-466214-95c689d94120.json'
SCOPES = ['https://www.googleapis.com/auth/cloud-platform']

credentials = service_account.Credentials.from_service_account_file(
    SERVICE_ACCOUNT_FILE, scopes=SCOPES
)
access_token = credentials.token
if not access_token or credentials.expired:
    credentials.refresh(requests.Request())
    access_token = credentials.token

# URL of deployed Cloud Run service
base_url = 'https://titanic-88146497745.europe-west1.run.app/predict'

# Prepare the data as JSON
data = titanic_df.to_dict(orient='records')

# Build and perform the POST request
headers = {
    'Authorization': f'Bearer {access_token}',
    'Content-Type': 'application/json'
}
response = requests.post(base_url, headers=headers, json=data)

# Print the response status and the prediction result
print(response.status_code)
print(response.json())