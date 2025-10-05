# CloudCast — iOS Video Upload App using AWS Amplify & S3

CloudCast is a SwiftUI iOS app that lets users record or select videos and upload them to **Amazon S3** using **AWS Amplify**.  
It includes real-time upload progress, Cognito-based authentication, and presigned URLs to securely view uploaded files.

---

## Table of Contents
- [Overview](#-overview)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Step-by-Step Setup](#-step-by-step-setup)
- [AWS Amplify Commands](#-aws-amplify-commands)
- [iOS Configuration](#-ios-configuration)
- [Testing Uploads](#-testing-uploads)
- [Viewing Videos in S3](#-viewing-videos-in-s3)

---

## Overview

CloudCast demonstrates how to:
- Configure **AWS Amplify** in an iOS app
- Connect to **Cognito** for guest/auth user access
- Upload videos to **S3**
- Track upload progress in real time
- Retrieve a temporary **presigned URL** for secure playback

---

## Features

| Feature | Description |
|----------|--------------|
| File Picker | Select videos (.mp4) from Files app |
| S3 Integration | Uploads stored in your Amplify-managed S3 bucket |
| Cognito Auth | Supports guest and authenticated access |
| Upload Progress | Real-time progress updates using Swift Concurrency |
| Presigned URL | Secure, expiring link for viewing uploaded video |

---

## Tech Stack

- **SwiftUI**
- **AWS Amplify**
  - `AWSCognitoAuthPlugin`
  - `AWSS3StoragePlugin`
- **Amazon Cognito** (Auth)
- **Amazon S3** (Storage)

---

## Step-by-Step Setup

### **Step 1 — Install Amplify CLI**
```bash
npm install -g @aws-amplify/cli
amplify --version
```

### **Step 2 — Configure AWS CLI**
Link your IAM credentials:
```bash
aws configure
```
Enter:

- Access Key ID

- Secret Access Key

- Region: us-east-1

- Output: json

### **Step 3 — Initialize Amplify**
In your iOS project root:
```bash
amplify init
```
Choose:
```yaml
? Project name: CloudCast
? Environment name: dev
? Default editor: Xcode
? App type: iOS
? Initialize? Yes
? Authentication method: AWS profile
```

### **Step 4 — Add Authentication**
```bash
amplify add auth
```
Choose **Default configuration**.

### **Step 5 — Add S3 Storage**
```bash
amplify add storage
```
Choose:
```pgsql
? Service: Content (Images, audio, video, etc.)
? Friendly name: s3cloudcast
? Bucket name: cloudcast-[unique-id]
? Access: Auth and guest users
? Auth users: create/update, read, delete
? Guest users: create/update, read, delete
? Add Lambda trigger? No
```

### **Step 6 — Push to AWS**
```bash
amplify push
```
Confirm with **Yes** to deploy resources (Cognito + S3).

### **Step 7 — Verify Config Files**
After pushing, ensure these files are inside your Xcode project:

-```amplifyconfiguration.json```

-```awsconfiguration.json```
Add both under:
```rust
Build Phases → Copy Bundle Resources
```
## Testing Uploads

Follow these steps to test video uploads in your app:

### Step 1: Build and Run
Open your project in **Xcode**, then **build and run** the app on a simulator or physical device.


### Step 2: Upload a Video
1. Tap **Select & Upload Video** in the app.  
2. Choose any `.mp4` file from the **Files** app.  
3. Watch the **upload progress** as the file is sent to your S3 bucket.


### Step 3: Get the Video URL
Once the upload is complete:
- Copy the **signed URL** printed in Xcode’s **console**, or  
- Use the **URL displayed on screen** within the app.


###  Step 4: Test the Video
1. Open **Safari** (or any browser).  
2. Paste the **signed URL** into the address bar.  
3. Your video should start playing!


## Viewing Videos in S3

Follow these steps to verify your uploaded videos in AWS S3:


### Step 1: Open the S3 Console
Go to the [**AWS S3 Console**](https://s3.console.aws.amazon.com/s3/home).


### Step 2: Find Your Bucket
Locate your project bucket:
```
cloudcast0f7f4bac2dac49ccafdfd15850bc7c0607b79-dev
```
### Step 3: Navigate to Uploads
1. Open the bucket.  
2. Navigate to the **uploads/** folder.  
3. Confirm your uploaded **.mp4** video file appears in the list.

### Step 4: Handle AccessDenied
If clicking the object results in an **AccessDenied** error:

- This means the file isn’t publicly accessible.
- Instead, use the **presigned URL** generated in your app — it provides **temporary and secure access** to the video.

**Tip:** Presigned URLs expire after a short period, so regenerate one if it no longer works.

