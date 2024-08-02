# Amazon Bedrock Chatbot Demo

A simple chatbot capable of conducting general and document based
conversations using the Amazon Bedrock API including the required
configuration for deployment on Divio Cloud.

## Technology Stack

- Python
- Docker
- Streamlit
- Amazon Bedrock API

## Requirements

- Python needs to be installed on your machine. If you don't have it
already, you can download it [here](https://www.python.org/downloads/).

- Docker is optional for local development but required for deployment on
Divio Cloud. Docker can be downloaded
[here](https://www.docker.com/products/docker-desktop).


## Local Development

#### Step 1: Clone the repository

```bash
git clone https://github.com/divio/amazon-bedrock-chatbot-demo.git
```

#### Step 2: Navigate to the project directory

```bash
cd amazon-bedrock-chatbot-demo
```

#### Step 3: Create a virtual environment

```bash
python -m venv venv
```

#### Step 4: Activate the virtual environment

```bash
source venv/bin/activate (Linux/Mac) or venv\Scripts\activate (Windows)
```

#### Step 5: Install the required packages

```bash
pip install -r requirements.txt
```

#### Step 6: Run the app locally

Option 1: Run the app locally using Python:

```bash
streamlit run app.py
```

Option 2: Run the app locally using Docker:
```bash
docker build -t amazon-bedrock-chatbot-demo .
docker run --rm -p 80:80 amazon-bedrock-chatbot-demo
```

Open your browser and navigate to the URL displayed in the terminal
depending on the option you chose.

## Amazon Bedrock Setup

This chatbot requires:
- AWS credentials with access to the Amazon Bedrock API
- Requesting access to a model provided by Amazon Bedrock
- Access to an S3 bucket where the documents will be stored
- Configuring a Vector Store for the Knowledge Base

The first two requirements should be enough for general conversations while
the rest are needed for document based conversations.

#### Step 1: Create an AWS account([docs](https://aws.amazon.com/free/))

#### Step 2: Create an IAM user ([docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create))

#### Step 3: Attach the `AmazonBedrockFullAccess` policy to the IAM user  ([docs](https://docs.aws.amazon.com/apigateway/latest/developerguideapi-gateway-create-and-attach-iam-policy))

#### Step 4: Create an access key for the IAM user ([docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys))

#### Step 5: Request access to a model provided by Amazon Bedrock ([docs](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access))

You can already navigate back to your browser and start interacting with the
chatbot for general conversations using this access key. Follow the
instructions displayed in the chatbot interface to start the conversation.
This will require authenticating using the access key and selecting both the
region and the model you have access to. Remember, the model you requested
access to was also grouped under a specific region. Make sure to select that
same region in the chatbot interface.

> [!WARNING]
> Depending on the model, AWS will charge you based on usage. Although we might
> talk about pennies here, it's always good to keep an eye on the costs as
> pennies can easily turn into dollars if you're not careful.
> For text-generation models, such as those we are using here, you will be
> charged for every input token processed and every output token generated. For
> more information on pricing, have a look [here](https://aws.amazon.com/bedrock/pricing).

## Creating a Knowledge Base for Document Based Conversations

To enable document based conversations, you need to create a Knowledge Base
in Amazon Bedrock, upload the documents to an S3 bucket attached to that
Knowledge Base as well as configuring a Vector Store.

#### Step 1: Attach the `AmazonS3FullAccess` policy to the IAM user ([docs](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-create-and-attach-iam-policy)).

#### Step 2: Create an S3 bucket ([docs](https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html)).

#### Step 3: Attach the `IAMFullAccess` policy to your IAM user ([docs](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-create-and-attach-iam-policy)).

> [!CAUTION]
> Please note that we are giving our IAM user too much power here. This is just
> for the sake of simplicity. In a real-world scenario, you would want to follow
> the principle of least privilege and only grant the necessary permissions. For
> example, there is no need for full access to all S3 buckets, just the ones you
> want to use. The same applies tenfold for the `IAMFullAccess` policy. This one
> is added just to avoid an issue while creating the Knowledge Base and it is
> related to creating an IAM role that will handle the permissions for the
> actions performed by the Knowledge Base. You can, and probably should, remove
> the `IAMFullAccess` policy after the Knowledge Base is created. The other two
> (`AmazonBedrockFullAccess` and `AmazonS3FullAccess`) are needed for the
> chatbot to function properly. As a side note, root users cannot create
> Knowledge Bases and this is the reason behind the hustle of creating and
> properly configuring this IAM user.


#### Step 4: Navigate to the Amazon Bedrock console to create a Knowledge Base

Search for `Amazon Bedrock` in the AWS Management Console and click on it.
Next, click on `Get started` and you will find yourself in the main dashboard
of the Bedrock console. Click on `Knowledge bases` in the left-hand menu and
then on `Create Knowledge Base`.

#### Step 5: Providing the Knowledge Base Details

You can give your Knowledge Base a name and a description (optional) but
other than that, proceed with the default settings. Notice that `Amazon S3`
is selected as the data source type. Hit `Next`.

#### Step 6: Configuring the Data Source

Click on `Browse S3` and select the bucket you created earlier. Once again,
proceed with the default settings for the rest of the options.

#### Step 7: Selecting an Embeddings Model

Select one of the available embeddings models. For this tutorial, we'll go
on with the default one provided by Amazon (`Titan Embeddings G1 - Text v1.2`).
You are free to select any other model but I would strongly suggest sticking
with the default one as some of the next steps will depend on it.

#### Step 8: Configuring the Vector Store

This is probably the most demanding step in terms of configuration. You can
either proceed with the default one provided by Amazon (`Amazon OpenSearch
Serverless vector store`) or create your own. Although the default one seems
tempting, there are some caveats to it. Amazon is, at the time of writing,
actively improving the pricing algorithms for this service but it might still
be a bit expensive for simple use cases such as our own. For more information,
have a look [here](https://aws.amazon.com/opensearch-service/pricing/).

That being said, we will proceed using `Pinecone` as our vector store and
leverage their free tier, which is more than enough for our use case. To be
able to do so, you need to create a `Pinecone` account first. Visit their
website [here](https://www.pinecone.io/) and sign up. Once you have an
account, log in and create a new index. To do so, select `Indexes` from the
left-hand menu and then click on `Create index`.

Give your index a name and assign `1536` as the value for the `Dimension`
field. Hit `Create index` and you are good to go. This is the exact same value
as the one in the `vector dimensions` field for the `Titan Embeddings G1 - Text
v1.2` model back in the Bedrock console. This is not a coincidence. The vector
store needs to have the same dimensionality as the embeddings model. This is
crucial for the RAG technique to work properly.

Hit `Create index`. Once the index is created, copy the `Host` value at the
top and head back to the Bedrock console. Paste the `Host` value in the
`Endpoint URL` as shown below.

For the next field (`Credentials secret ARN`), you need to create a secret in
AWS `Secrets Manager`. This secret will hold the API key for your Pinecone
index in an encrypted form. To do so, search for `Secrets Manager` in the AWS
Management Console and click on it. Next, click on `Store a new secret` and
select `Other type of secret`. For the `Key/value` pair, it's crucial that the
key is `apiKey` spelled exactly like that. For the value, paste the API key
you got from Pinecone. Hit `Next` and follow the rest of the steps to create
the secret. Once the secret is created, copy its `Secret ARN` and paste it in
the `Credentials secret ARN` field back in the Bedrock console.

Use the default values suggested for the last two required fields:

- Text field name: `text`
- Bedrock-managed metadata field name: `metadata`

and hit `Next`.

Make sure everything is set up as expected and hit `Create Knowledge Base`.

## Utilizing the Knowledge Base

Head back to the chatbot and select your newly created Knowledge Base from the
selector.

Knowledge base search mode is now enabled. In this mode, the chatbot will only
respond based on the context of the documents in your Knowledge Base. If no
relevant information is found, the chatbot will respond with a generic message
stating that it cannot assist you with that request. Let's upload a document
and see how the chatbot can help us with it.

Right below the Knowledge Base selector, select a data source (the S3 bucket
you created and attached to the Knowledge Base earlier) and upload a document.

Hit `Upload & Sync`.

The document is being uploaded to the S3  bucket and then processed by the
Knowledge Base. In other words, the document has been read and understood by
the chatbot. Go ahead and ask a question related to the document you just
uploaded!

## Deploying Your Chatbot on Divio Cloud

The Dockerfile included in this repository is all you need to deploy your
chatbot on Divio Cloud. The only thing you need to do is to create a new
project on Divio Cloud.

#### Step 1: Create a Divio Account

If you don't already have one, create a Divio account by signing up
[here](https://auth.divio.com/realms/cloud-users/protocol/openid-connect/registrations?response_type=code&client_id=control-panel&redirect_uri=https://control.divio.com&ref=divio-signup).
Once registered, log in to proceed.

#### Step 2: Creating and Configuring a New Application

1. Create Application: Click on the Plus icon (+) in the left-hand menu to
create a new application
2. Repository Setup: Select `I already have a repository`. You can fork the
repository provided in this blog post and use it freely as your own. For more
information on how to fork a repository, have a look
[here](https://docs.github.com/en/get-started/quickstart/fork-a-repo).
3. Connect Repository: Select either "Connect to GitHub" or "Provide a git
URL". Both are fine but let's go with the latter for simplicity here. The
wizard will guide you through all the necessary steps. For more information
and all the available ways to connect a repository with your Divio
application, have a look
[here](https://docs.divio.com/features/repository/#how-to-configure-external-git-hosting)
4. Application Details: Name your application and choose a plan. `Free Trial`
is selected by default. Expand the `Customize Subscription` section to
confirm. Leave other settings as default.
5. Finalize Creation: Click `Create application` and you're done. After that,
you will end up in the main view of a Divio application.

#### Step 3: Configure Webhook (Optional)

Connect a Webhook to your repository (optional). From the left-hand menu on
your application view click on `Repository` and add a new webhook. After
completing the required steps, you will have a webhook set up. This will allow
Divio to listen for changes in your repository and automatically include those
changes in each new deployment. For more information on how to set up a webhook,
have a look
[here](https://docs.divio.com/features/repository/#configure-a-webhook-for-the-git-repository-recommended).

#### Step 4: Deploy Your Application

1. Initiate Deployment: Back in the main view of your application, click on
`Deploy` on any of the available environments. Environments is a powerful
feature of Divio that allows you to have different stages of your application,
such as development (test), production (live) and so forth. For now, let's
just deploy the default test environment. For more information on
environments, have a look
[here](https://docs.divio.com/features/environments/).
2. Payment Method: You will be asked to provide a payment method if you
haven't already. Don't worry, you won't be charged anything, you are in the
free trial after all. This is just a security measure to prevent abuse of
this plan. Once you've provided the payment method, sit back and relax. Your
application is being deployed. You can follow the progress right from the view
you're in.
3. Monitor Deployment: Watch the deployment progress in the current view. Once
completed, you can access your application via the newly activated environment
URL. That's it! Your chatbot is now live!
