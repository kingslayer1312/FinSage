## FinSage

FinSage is a mobile application built with Flutter that empowers users to track their stock investments, receive ML-powered stock predictions, and leverage a built-in chatbot to enhance their financial knowledge. 

### Core Functionalities

* **Portfolio Tracking:** The application facilitates the monitoring of investment performance with real-time data, providing users with a clear visualization of gains and losses against initial purchase prices.
* **Watchlist Management:** Users can create a personalized watchlist to stay informed about market movements for stocks that interest them.
* **AI-Driven Insights:** FinSage integrates with Gemini Pro, a cutting-edge large language model, to provide users with personalized financial analysis and recommendations for their investments. **Disclaimer:** Stock recommendations are provided for informational purposes only and should not be construed as financial advice.
* **Predictive Analytics (Beta):** FinSage utilizes a Long Short-Term Memory (LSTM) model built with TensorFlow to offer future price predictions for a select group of stocks (currently limited to AMD, Amazon, and Alphabet Inc.). The model can be found at https://github.com/kingslayer1312/StockPrediction
* **Secure User Authentication:** The application prioritizes the confidentiality and integrity of user financial data through robust Firebase authentication protocols.

### Technology Stack

* **Frontend Development:** Flutter
* **Backend Infrastructure:** Firebase
* **AI Integration:** Gemini Pro
* **Stock Prediction (Beta):** TensorFlow

### Getting Started

**Prerequisites:**

* A fully configured Flutter development environment ([https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install))
* A Firebase project with established authentication and database functionalities ([https://firebase.google.com/docs/projects/api/workflow_set-up-and-manage-project](https://firebase.google.com/docs/projects/api/workflow_set-up-and-manage-project))
* Two API keys are required: Gemini Pro and Finnhub
* Create a folder named 'api' within the lib folder and add three files:

**firebase_api.dart**
```dart
const API_KEY = '<YOUR_PROJECT_API_KEY>';
const APP_ID = '<YOUR_PROJECT_APP_ID>';
const MESSAGING_SENDER_ID = '<YOUR_PROJECT_MESSAGING_SENDER_ID>';
const PROJECT_ID = '<YOUR_PROJECT_ID>';
```

**gemini_api.dart**
```dart
const GEMINI_API_KEY = '<YOUR_GEMINI_PRO_API_KEY>';
```

**stock_api.dart**
```dart
const STOCK_API_KEY = '<YOUR_FINNHUB_API_KEY>';
```

**Setup Instructions:**

1. Clone the repository.
2. Install project dependencies using the following command:
  ```bash
  flutter pub get
  ```
3. Replace placeholder values within `firebase_options.dart` with the user's unique Firebase project credentials.
4. Initiate the application:
  ```bash
  flutter run
  ```
