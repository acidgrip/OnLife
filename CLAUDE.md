# Project Name: [OnLife] (SwiftUI iOS Target)

## Tech Stack & Environment
- **Framework**: SwiftUI (Strictly Native, NO UIKit overrides unless requested)
- **Language**: Swift 6 (Strict Concurrency Enabled)
- **Target**: iOS 17+ (Leverage modern features globally. Prefer `@Observable` over legacy `ObservableObject`)
- **Data Persistence**: SwiftData / Core Data [Specify yours]
- **Dependency Management**: Swift Package Manager (SPM) only. Do not use CocoaPods.
- **Build Commands**:
  ```bash
  xcodebuild -project App.xcodeproj -scheme App -destination 'platform=iOS Simulator,name=iPhone 15' build
  ```

---

## Project Structure

- **MANDATORY**: Organize code by feature, not by type.
- **MANDATORY**: Every new feature MUST be created in its own folder under `Features/`.
- **MANDATORY**: Test files MUST mirror the exact folder structure of the source code.

Example:

```text
Features/
├── Authentication/
│   ├── LoginView.swift
│   ├── LoginStore.swift
│   └── AuthenticationService.swift
├── Profile/
│   ├── ProfileView.swift
│   ├── ProfileEditorView.swift
│   └── ProfileStore.swift
├── Events/
│   ├── EventFeedView.swift
│   ├── EventDetailView.swift
│   └── EventStore.swift

OnlifeTests/
├── Features/
│   ├── Authentication/
│   │   ├── LoginStoreTests.swift
│   │   └── AuthenticationServiceTests.swift
│   ├── Profile/
│   │   └── ProfileStoreTests.swift
│   └── Events/
│       └── EventStoreTests.swift

Shared/
├── DesignSystem/
├── Services/
├── Extensions/
└── Utilities/
```

### Folder Structure Rules:

1. **Feature Folders**: Each feature (e.g., Authentication, Profile, Events, Posts) gets its own folder under `Features/`.
2. **No Loose Files**: Do NOT place feature files directly in the root `Features/` folder or project root.
3. **Mirrored Test Structure**: Test files MUST be organized in `OnlifeTests/Features/` with the SAME folder structure as `Features/`.
4. **Clear Ownership**: Each feature folder owns all its views, stores, services, and models.
5. **Shared Resources**: Only truly shared/reusable code goes in `Shared/`.

### File Placement Examples:

✅ **CORRECT:**
```
Features/Authentication/LoginView.swift
Features/Authentication/LoginStore.swift
OnlifeTests/Features/Authentication/LoginStoreTests.swift
```

❌ **WRONG:**
```
Features/LoginView.swift  (no feature folder)
LoginView.swift            (in project root)
OnlifeTests/LoginStoreTests.swift  (not mirroring structure)
```

- New files should be placed in the most relevant feature folder.
- Avoid giant "Helpers", "Managers", or "Utils" dumping grounds.
- Maintain clear ownership boundaries between features.

---

## Architecture & State Guidelines

- **Pattern**: Lean View Composition. Views represent state directly. Avoid bloated ViewModels. Do NOT generate over-engineered MVVM layers unless complexity clearly justifies them.
- **State Flow**:
  - `@State` for local state
  - `@Binding` for downstream state propagation
  - `@Environment` for dependency injection
- **Modern Syntax**: Use the `@Observable` macro for shared state containers. Do not introduce new `ObservableObject` implementations.
- **Async Execution**: Use `.task {}` for async triggers and loading operations.
- **Concurrency**:
  - Use strict Swift 6 concurrency compliance.
  - Isolate UI-facing logic with `@MainActor`.
  - Use custom global actors where appropriate.
  - Never use detached tasks unless explicitly justified.
  - Address Sendable violations correctly instead of suppressing warnings.

---

## Dependency Injection

- Prefer Environment-based dependency injection.
- Services should be injected through Environment values.
- Avoid singleton patterns unless explicitly required.
- Views should not instantiate networking, persistence, analytics, or service objects directly.
- Dependencies must be mockable for previews and tests.

---

## Navigation

- Use `NavigationStack` exclusively.
- Prefer strongly typed navigation models.
- Avoid string-based routing.
- Navigation state should be owned by feature-level state containers.
- Sheets, popovers, alerts, and full-screen covers should use enum-driven presentation where practical.

---

## SwiftData

- Prefer SwiftData over custom persistence implementations.
- Use `@Query` for straightforward fetch operations.
- Keep persistence operations outside View bodies.
- Inject `ModelContext` dependencies.
- Avoid fetch logic inside reusable view components.
- Prefer lightweight migrations when possible.

---

## Development Workflow

### Planner Mode

1. **Analyze**
   - State the task goals.
   - Identify affected files and dependencies.
   - Highlight risks or architectural considerations.

2. **Plan**
   - For architectural changes, new features, or modifications affecting multiple files, present a plan and wait for approval.
   - For small bug fixes, isolated refactors, or single-file changes, proceed directly with implementation.

3. **Execute**
   - Create localized changes.
   - Modify the minimum number of files necessary.
   - Add tests when applicable.

---

## Code Style & Constraints

### File Organization

- One primary type per file.
- Every View, Store, Service, and Model should have its own file.
- Avoid multiple unrelated types in the same file.

### Size Limits

- Keep Views under 300 lines.
- Keep functions under 30 lines.
- Recommend refactoring when limits are exceeded.
- Extract reusable subviews when complexity grows.

### SwiftUI Rules

- Break complex views into focused subviews.
- Avoid large computed view properties.
- Use native stacks, grids, and layout APIs.
- Avoid hardcoded frame sizes unless required by design.
- Never perform networking, persistence, or heavy computation inside `body`.

### Design System

- Never hardcode colors.
- Never hardcode spacing values repeatedly.
- Use design tokens:
  - `Color.themePrimary`
  - spacing constants
  - typography tokens
- Reuse existing design system components before creating new ones.

### Assets

- Use SF Symbols by valid system name only.
- Do not invent symbol names.
- Use asset catalog resources when appropriate.

### Native Framework Preference

- Prefer Apple frameworks first:
  - SwiftData
  - URLSession
  - Network
  - CryptoKit
  - Observation
- Do not introduce third-party packages without explicit approval.

### AI Code Generation Rules

- Modify the smallest number of files necessary.
- Preserve existing architecture unless instructed otherwise.
- Preserve project naming conventions.
- Avoid speculative abstractions.
- Do not create protocols solely for future flexibility.
- Do not generate placeholder implementations that compile but provide no behavior.
- If requirements are ambiguous, ask clarifying questions before implementation.
- Prefer extending existing components over creating new architecture.

### Git Safety

- Never execute destructive Git commands.
- Never perform automatic commits.
- Never reset, clean, or discard uncommitted work.

---

## Networking

- Use URLSession unless otherwise requested.
- Use async/await APIs.
- Create strongly typed request and response models.
- Do not decode JSON directly in Views.
- Support cancellation for long-running requests.
- Explicitly model:
  - Loading
  - Success
  - Empty
  - Error states

---

## Accessibility

- Every interactive control must have accessibility labels.
- Images conveying information require accessibility descriptions.
- Decorative images should be hidden from accessibility.
- Verify VoiceOver navigation order.
- Support Dynamic Type.
- Do not disable text scaling without approval.
- Ensure touch targets are at least 44x44 points.
- Prefer semantic SwiftUI accessibility APIs.

---

## Performance

- Avoid unnecessary re-renders.
- Prefer value types when possible.
- Avoid expensive computed properties in View bodies.
- Use lazy containers for large collections.
- Profile before introducing caching.
- Do not prematurely optimize.
- Consider memory impact when loading images and large datasets.

---

## Security & Privacy

- Never hardcode API keys or secrets.
- Use Keychain for sensitive credentials.
- Store configuration appropriately.
- Follow least-privilege principles.
- Avoid logging personal or sensitive user data.
- Validate external input before processing.

---

## Testing & Quality Assurance

### Framework

- **MANDATORY**: Use Swift Testing (`@Test`, `#expect`).
- Avoid introducing XCTest.

### Test Coverage - MANDATORY

**🚨 CRITICAL RULE: ALL code generation MUST include corresponding unit tests. No exceptions.**

**This rule applies to:**
- ✅ ALL new features
- ✅ ALL Stores (state management logic)
- ✅ ALL Services (business logic, API calls, data processing)
- ✅ ALL Data transformations and utilities
- ✅ ALL computed properties with business logic
- ✅ ALL State transitions and side effects
- ✅ ALL bug fixes that modify logic
- ❌ Simple SwiftUI Views (optional, focus on logic)

**Code generation without tests is considered INCOMPLETE and INVALID.**

1. **Folder Structure Requirements:**
   - **MANDATORY**: Each new feature MUST be created in its own folder under `Features/FeatureName/`
   - **MANDATORY**: Each new feature MUST have a corresponding test folder under `OnlifeTests/Features/FeatureName/`
   - **MANDATORY**: Create BOTH folders even if they don't exist yet
   - **MANDATORY**: Tests MUST mirror the exact folder structure of source files

2. **Test File Location:**
   - **MANDATORY**: Tests MUST mirror the exact folder structure of source files
   - Example: `Features/Authentication/LoginStore.swift` → `OnlifeTests/Features/Authentication/LoginStoreTests.swift`
   - Example: `Features/Profile/ProfileService.swift` → `OnlifeTests/Features/Profile/ProfileServiceTests.swift`

3. **Test Naming Convention:**
   - Test files: `{SourceFileName}Tests.swift`
   - Test suites: Match the class/struct name
   - Example: `LoginStore.swift` → `LoginStoreTests.swift`

4. **Build Requirements:**
   - **MANDATORY**: All generated code MUST result in a clean build
   - **MANDATORY**: All tests MUST pass
   - **MANDATORY**: The application MUST be runnable after code generation
   - Fix all compiler errors and warnings before considering work complete

### Test Structure Example:

```swift
import Testing
@testable import OnLife

@Suite("Login Store Tests")
struct LoginStoreTests {
    
    @Test("Login with valid credentials succeeds")
    func loginWithValidCredentials() async throws {
        let store = LoginStore()
        
        await store.login(email: "test@example.com", password: "password123")
        
        #expect(store.isLoading == false)
        #expect(store.showError == false)
    }
    
    @Test("Login with invalid email shows error")
    func loginWithInvalidEmail() async throws {
        let store = LoginStore()
        
        await store.login(email: "invalid", password: "password123")
        
        #expect(store.showError == true)
        #expect(store.errorMessage != nil)
    }
}
```

### Test Coverage Guidelines

- Add tests for:
  - Business logic
  - State transitions
  - Data transformations
  - Validation logic
  - Error handling
- Prefer deterministic tests.
- Mock dependencies where appropriate.
- Test edge cases and error conditions.
- Avoid testing implementation details.

### Error Handling

- Handle errors explicitly.
- Present meaningful UI error states.
- Do not silence failures using `try?` unless intentionally documented.

### Build Validation

- Ensure generated code compiles.
- Verify strict concurrency compliance.
- Resolve warnings instead of suppressing them.

---

## Preview Standards

- Every new View must include a `#Preview`.
- Use static preview data.
- Never perform network requests in previews.
- Never depend on production services in previews.
- Preview:
  - Loading state
  - Success state
  - Empty state
  - Error state
  - Dark mode where applicable

---

## Workflow Execution Protocol

### Phase 1 — Planner

- Analyze requirements.
- Explain reasoning.
- Present implementation plan when required.
- Await approval for significant changes.

### Phase 2 — Implementation

- **Create proper folder structure** for new features under `Features/FeatureName/` (create folder if it doesn't exist).
- **Create corresponding test folder and files** in `OnlifeTests/Features/FeatureName/` mirroring the source structure (create folder if it doesn't exist).
- **MANDATORY**: Write unit tests for ALL business logic (stores, services, utilities). Tests are NOT optional.
- Implement modular code.
- Follow project conventions.
- Validate formatting and compilation.
- **Verify ALL tests pass** before considering implementation complete.
- **Verify the app builds cleanly and runs** before considering implementation complete.

**📋 Code Generation Checklist:**
- [ ] Created feature folder in `Features/FeatureName/` (if new feature)
- [ ] Created test folder in `OnlifeTests/Features/FeatureName/` (if new feature)
- [ ] Implemented source code
- [ ] Implemented comprehensive unit tests
- [ ] All tests pass
- [ ] Code compiles with no errors
- [ ] App can run successfully
- [ ] No new warnings introduced

### Phase 3 — Reflection

Review changes for:

- Swift 6 concurrency compliance
- Accessibility and VoiceOver support
- Performance concerns
- Memory management
- Design system consistency
- Test coverage opportunities
- Unnecessary complexity or abstractions
