//
//  LoginItemList.swift
//  SlimHUD
//
//  Created by Alex Perathoner on 26/05/2020.
//  Copyright © 2020 Alex Perathoner. All rights reserved.
//

import Foundation
class LoginItemsList : NSObject {

	let loginItemsList : LSSharedFileList = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue();



	func addLoginItem() -> Bool {
		var path = LoginItemsList.appPath()
		if(getLoginItem() != nil) {
			print("Login Item has already been added to the list.");
			return true;
		}
		print("Path adding to Login Item list is: ", path);

		// add new Login Item at the end of Login Items list
		if let loginItem = LSSharedFileListInsertItemURL(loginItemsList,
														  getLastLoginItemInList(),
														  nil, nil,
														  path,
														  nil, nil) {
			print("Added login item is: ", loginItem);
			return true;
		}

		return false;
	}


	func removeLoginItem() -> Bool {
		
		var path = LoginItemsList.appPath()
		// remove Login Item from the Login Items list
		if let oldLoginItem = getLoginItem() {
			print("Old login item is: ", oldLoginItem);
			if(LSSharedFileListItemRemove(loginItemsList, oldLoginItem) == noErr) {
				return true;
			}
			return false;
		}
		print("Login Item for given path not found in the list.");
		return true;
	}


	func getLoginItem() -> LSSharedFileListItem! {
		
		var path = LoginItemsList.appPath()

		// Copy all login items in the list
		let loginItems : NSArray = LSSharedFileListCopySnapshot(loginItemsList, nil).takeRetainedValue();

		var foundLoginItem : LSSharedFileListItem?;
		var nextItemUrl : Unmanaged<CFURL>?;

		// Iterate through login items to find one for given path
		print("App URL: ", path);
		for var i in (0..<loginItems.count)  // CFArrayGetCount(loginItems)
		{

			var nextLoginItem : LSSharedFileListItem = loginItems.object(at: i) as! LSSharedFileListItem; // CFArrayGetValueAtIndex(loginItems, i).;


			if(LSSharedFileListItemResolve(nextLoginItem, 0, &nextItemUrl, nil) == noErr) {



				print("Next login item URL: ", nextItemUrl!.takeUnretainedValue());
				// compare searched item URL passed in argument with next item URL
				if(nextItemUrl!.takeRetainedValue() == path) {
					foundLoginItem = nextLoginItem;
				}
			}
		}

		return foundLoginItem;
	}

	func getLastLoginItemInList() -> LSSharedFileListItem! {

		// Copy all login items in the list
		let loginItems : NSArray = LSSharedFileListCopySnapshot(loginItemsList, nil).takeRetainedValue() as NSArray;
		if(loginItems.count > 0) {
			let lastLoginItem = loginItems.lastObject as! LSSharedFileListItem;

			print("Last login item is: ", lastLoginItem);
			return lastLoginItem
		}

		return kLSSharedFileListItemBeforeFirst.takeRetainedValue();
	}

	func isLoginItemInList() -> Bool {

		if(getLoginItem() != nil) {
			return true;
		}

		return false;
	}

	static func appPath() -> CFURL {

		return NSURL.fileURL(withPath: Bundle.main.bundlePath) as CFURL;
	}

}
