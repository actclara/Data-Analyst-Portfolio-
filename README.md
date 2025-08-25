# Alicia Clara Trevina's Data Analyst Portfolio 

Below are some of the projects that I've built over the past few years to further my experience in data analytics, understand the complex challenges of how to relay important
information and insights based on the intended audience. Few tools I have used includes: Python, R, and Power BI. 

### Topic Modelling Project: Churn Rate Prediction for Fashion Subscription Services (Rent the Runway) 
Warwick Business School - Internal Dissertation 

Developed two multimodal churn prediction models which utilises Latent Dirichlet Allocation and BERTopic to extract latent topics from review texts and use Logistic Regression to finally classify the customers as churned or not. Additionally, a singlemodal model of Logistic Regression is used as a benchmark model. 


### Machine Learning Project – Review Prediction for E-commerce Platform (Nile)
Warwick Business School – Analytics in Practice, Group Project

Developed a machine learning solution for Nile, a Brazilian e-commerce platform, to predict and increase the likelihood of customers leaving positive reviews—improving brand reputation and customer engagement.

CRISP DM Methodology Outline 
Business & Data Understanding:
• Framed a business problem around incentivizing positive reviews.

• Followed CRISP-DM methodology from data prep to model deployment.

Data Engineering:
• Merged and cleaned datasets (~99K records, 24 variables).

• Performed feature engineering (geolocation, payment method encoding, delivery metrics).

Exploratory Data Analysis (EDA):

• Identified key drivers of positive feedback such as last-mile delivery, Boleto payments, and seller-customer location proximity.

• Visualized trends in review scores across time, geography, and product categories.

Predictive Modelling:
• Tested 3 classification models: XGBoost, Gradient Boosted Decision Trees, and Random Forest.

• Applied SMOTE to address class imbalance; tuned hyperparameters.

• Achieved 84% accuracy in predicting positive reviews using XGBoost.

Business Insights & Recommendations:
• Suggested voucher campaigns, Boleto partnerships, and operational tweaks.

• Proposed integration with CRM for real-time targeting and automation of incentives.

Next Steps:
• Recommended sentiment analysis for text reviews, better data infrastructure, and expanded feature sets (e.g., warehouse geolocation).



### SQL Data Analysis - Subscription Analytics for Foodie-Fi

Main Objective: Analyzed subscription lifecycle data for a fictional streaming service offering food-related content, using PostgreSQL. Key achievements included:

• Customer Journey Mapping: Tracked onboarding paths and plan transitions (trial → basic/pro → churn) for individual users using window functions and joins.

• Cohort and Retention Analysis: Calculated churn rates, plan upgrade/downgrade trends, and time-to-upgrade using analytical functions like ROW_NUMBER, LAG, and DATE_PART.

• Revenue Modeling: Designed a custom payments table to simulate monthly and annual billing logic, proration during upgrades, and billing cutoff on churn.

• KPI Development: Generated metrics including active users, churn %, upgrade timelines, and plan distribution snapshots as of specific dates.

• Business Insights: Identified key customer behaviors and proposed data-driven strategies to improve retention, enhance onboarding, and guide pricing.

### SQL Data Analysis - Operational Analytics for Pizza Runner 
Conducted comprehensive SQL analysis for a fictional pizza delivery startup to improve operations, customer experience, and ingredient optimization. 
Project involved cleaning messy data, deriving key metrics, and simulating business logic using advanced SQL.

• Data Cleaning & Transformation: Parsed and standardized free-text fields (exclusions, extras, distance, duration) and handled NULLs and inconsistent formats.

• Operational Metrics: Calculated KPIs including delivery success rates, order volumes by time, average delivery time, and runner performance (speed, efficiency).

• Customer & Product Insights: Identified most popular pizzas, extras, exclusions, and unique customer order patterns.

• Ingredient Usage & Menu Optimization: Quantified ingredient consumption across all delivered orders to inform inventory planning and potential menu expansion.

• Revenue Modeling: Estimated revenue based on pizza pricing, runner payouts, and extras using CASE logic; simulated changes in profitability with pricing tweaks.

• Relational Data Modeling: Proposed schema changes (e.g., for pizza ratings and new menu items) to ensure database scalability and normalize complex data.




### Data Cleaning and Data Management on Amazon Sales in India using PostgreSQL 
• Conducted data walkthrough, data cleaning of the Amazon Sales Dataset based in Kaggle. 

• Investigated the main categories sold in Amazon and built a summary financial result of the main category list. 

### Respiratory Diseases Analysis on Infants using R (GLM)
• Analyzed data on 18,000+ infants from 40 countries to identify risk factors associated with respiratory disease.

• Conducted exploratory data analysis, chi-square tests, and t-tests to evaluate the influence of categorical and continuous variables (e.g., delivery type, air pollution, feeding method).

• Built a logistic regression model using stepwise forward selection, identifying key predictors including gestational diabetes, air pollution index (API), sleep hours, and feeding method.

• Achieved a 66.7% prediction accuracy on test data; reported variable odds ratios and 95% confidence intervals to interpret health risk impacts.

• Proposed future enhancement using Cox proportional hazards model for time-to-event prediction.


### Car Insurance Claim Multivariate Analysis using R 
• Performed canonical correlation analysis and hypothesis testing on a dataset of 3,000+ car insurance records to identify key factors influencing claim amounts.

• Built a Linear Discriminant Analysis (LDA) model achieving 72% classification accuracy, providing predictive insights into high-claim scenarios.

### Customer Analytics on a Chicago-Based Bike-Sharing Company using Python 🚲
• Assessed 12-month customer bike sharing data to convert non-membership holders into annual members using Pandas.

• Summarised key insights on Power BI dashboard.


### Maven Grocery Chain Data Visualization

• Utilized Power BI to clean, analyze, and visualize two years of sales, customer, and financial data from the Maven Grocery Chain.

• Designed an interactive dashboard delivering actionable insights across customer behavior, revenue trends, and product performance, enhancing data-driven decision-making.




