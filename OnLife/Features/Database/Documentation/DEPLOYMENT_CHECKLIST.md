# Firebase Deployment Checklist

Use this checklist when deploying your Onlife app to production with Firebase.

## Pre-Deployment

### Firebase Setup
- [ ] Firebase project created
- [ ] iOS app registered in Firebase Console
- [ ] `GoogleService-Info.plist` downloaded and added to Xcode project
- [ ] Bundle ID matches between Firebase and Xcode
- [ ] Firebase SDK added via Swift Package Manager
- [ ] `FirebaseApp.configure()` called in app initialization

### Firestore Database
- [ ] Firestore database created
- [ ] Database location selected (choose closest to users)
- [ ] Production security rules deployed
- [ ] Indexes created for:
  - [ ] Posts (timestamp + userId)
  - [ ] Events (date + location)
  - [ ] Comments (postId + timestamp)
- [ ] Test queries work in Firebase Console

### Firebase Storage
- [ ] Storage bucket created
- [ ] Storage security rules deployed
- [ ] File size limits configured (max 5MB)
- [ ] Content type restrictions set (images only)
- [ ] Test image upload works

### Firebase Authentication
- [ ] Authentication enabled
- [ ] Sign-in methods configured:
  - [ ] Email/Password
  - [ ] Apple Sign In (required for App Store)
  - [ ] Google Sign In (optional)
- [ ] Password policy configured
- [ ] Email verification enabled (recommended)
- [ ] Test authentication flow

### App Configuration
- [ ] Database configured to use Firebase in production:
  ```swift
  #if DEBUG
  DatabaseManager.shared.configure(with: .mock(simulatedDelay: 0.3))
  #else
  DatabaseManager.shared.configure(with: .firebase)
  #endif
  ```
- [ ] Feature flags configured appropriately
- [ ] Error handling tested
- [ ] Network timeout handling tested

## Security

### Firestore Rules
- [ ] Rules require authentication for all operations
- [ ] Users can only modify their own content
- [ ] Read permissions are appropriate
- [ ] Rules validated in Firebase Console

### Storage Rules
- [ ] Rules require authentication
- [ ] File size limits enforced
- [ ] Content type restrictions in place
- [ ] Users can only access their own uploads

### API Keys
- [ ] API keys restricted in Firebase Console
- [ ] iOS app restriction added
- [ ] Only necessary APIs enabled
- [ ] `GoogleService-Info.plist` NOT committed to public repositories

## Testing

### Unit Tests
- [ ] All database operations tested with mock
- [ ] Store logic tested
- [ ] Error handling tested
- [ ] Edge cases covered

### Integration Tests
- [ ] Test with real Firebase (staging environment)
- [ ] Create, read, update, delete operations work
- [ ] Real-time updates work
- [ ] Image uploads work
- [ ] Authentication flow works

### User Acceptance Testing
- [ ] Test on physical devices
- [ ] Test on different iOS versions
- [ ] Test with poor network conditions
- [ ] Test offline behavior
- [ ] Test with multiple users simultaneously

## Performance

### Optimization
- [ ] Pagination implemented for large datasets
- [ ] Query limits set appropriately
- [ ] Unnecessary real-time listeners removed
- [ ] Images compressed before upload
- [ ] Caching strategy implemented

### Monitoring
- [ ] Firebase Analytics enabled
- [ ] Crashlytics enabled
- [ ] Performance Monitoring enabled
- [ ] Key metrics identified and tracked

## App Store Preparation

### Required Features
- [ ] Apple Sign In implemented (required if using any auth)
- [ ] Privacy policy URL provided
- [ ] Terms of service URL provided
- [ ] Data usage description in Info.plist

### Privacy
- [ ] Privacy manifest (PrivacyInfo.xcprivacy) created
- [ ] Required Reason API usage declared
- [ ] Data collection disclosed
- [ ] Third-party SDK usage listed

### App Store Connect
- [ ] App created in App Store Connect
- [ ] Bundle ID matches
- [ ] App icon added (1024x1024)
- [ ] Screenshots prepared
- [ ] App description written
- [ ] Keywords selected

## Post-Deployment

### Monitoring
- [ ] Monitor Firebase Console for errors
- [ ] Check Crashlytics for crashes
- [ ] Review Analytics for user behavior
- [ ] Monitor API usage and costs
- [ ] Check performance metrics

### Maintenance
- [ ] Set up database backups
- [ ] Monitor storage usage
- [ ] Review and update security rules as needed
- [ ] Optimize queries based on usage
- [ ] Clean up old/unused data

### Scaling Considerations
- [ ] Monitor Firebase usage against free tier limits
- [ ] Plan for Blaze plan upgrade if needed
- [ ] Consider Firebase Functions for backend logic
- [ ] Implement caching strategy for frequently accessed data
- [ ] Consider CDN for static assets

## Firebase Limits to Monitor

### Firestore (Free Tier)
- **Reads**: 50K/day
- **Writes**: 20K/day
- **Deletes**: 20K/day
- **Storage**: 1 GB

### Storage (Free Tier)
- **Storage**: 5 GB
- **Downloads**: 1 GB/day
- **Uploads**: 1 GB/day

### Cloud Functions (Free Tier)
- **Invocations**: 125K/month
- **GB-seconds**: 40K/month
- **CPU-seconds**: 40K/month

When you exceed these limits, you'll need to upgrade to the Blaze (pay-as-you-go) plan.

## Support Resources

- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Firebase Status Page](https://status.firebase.google.com/)
- [Firebase Support](https://firebase.google.com/support)
- [Firebase Community](https://firebase.google.com/community)

## Emergency Rollback

If something goes wrong:

1. **Switch back to mock database:**
   ```swift
   DatabaseManager.shared.configure(with: .mock(simulatedDelay: 0.3))
   ```

2. **Disable problematic features:**
   ```swift
   FeatureFlags.realtimeFeed = false
   FeatureFlags.imageUpload = false
   ```

3. **Deploy hotfix via TestFlight**

4. **Investigate and fix issues**

5. **Re-enable Firebase when ready**

---

## Sign-Off

- [ ] All items checked
- [ ] Tested in staging environment
- [ ] Team reviewed
- [ ] Ready for production deployment

**Deployed by:** _______________  
**Date:** _______________  
**Version:** _______________

---

**Note:** Keep this checklist updated as your app evolves. Add new items as you discover them during development and deployment.
