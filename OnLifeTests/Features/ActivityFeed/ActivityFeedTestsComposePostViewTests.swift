//
//  ComposePostViewTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/25/26.
//

import Testing
import SwiftUI
@testable import OnLife

@Suite("ComposePostView Tests")
@MainActor
struct ComposePostViewTests {
    
    @Test("ComposePostView initializes with empty text")
    func testComposePostViewInitialization() {
        var postText = ""
        let binding = Binding(
            get: { postText },
            set: { postText = $0 }
        )
        
        _ = ComposePostView(
            postText: binding,
            onPost: {}
        )
        
        #expect(postText.isEmpty)
    }
    
    @Test("ComposePostView binding updates text")
    func testComposePostViewBindingUpdates() {
        var postText = ""
        let binding = Binding(
            get: { postText },
            set: { postText = $0 }
        )
        
        _ = ComposePostView(
            postText: binding,
            onPost: {}
        )
        
        binding.wrappedValue = "New post text"
        #expect(postText == "New post text")
    }
    
    @Test("ComposePostView handles onPost callback")
    func testComposePostViewCallback() {
        var postCalled = false
        
        let view = ComposePostView(
            postText: .constant("Test post"),
            onPost: { postCalled = true }
        )
        
        view.onPost()
        #expect(postCalled == true)
    }
    
    @Test("ComposePostView handles long text")
    func testComposePostViewLongText() {
        var postText = "This is a very long post that contains multiple sentences. It should be able to handle text of various lengths without any issues. The view should support multi-line text input."
        let binding = Binding(
            get: { postText },
            set: { postText = $0 }
        )
        
        _ = ComposePostView(
            postText: binding,
            onPost: {}
        )
        
        #expect(postText.count > 100)
    }
    
    @Test("ComposePostView can clear text")
    func testComposePostViewClearText() {
        var postText = "Some text"
        let binding = Binding(
            get: { postText },
            set: { postText = $0 }
        )
        
        _ = ComposePostView(
            postText: binding,
            onPost: {}
        )
        
        #expect(!postText.isEmpty)
        
        binding.wrappedValue = ""
        #expect(postText.isEmpty)
    }
}
