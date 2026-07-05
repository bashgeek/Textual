/* *********************************************************************
 *                  _____         _               _
 *                 |_   _|____  _| |_ _   _  __ _| |
 *                   | |/ _ \ \/ / __| | | |/ _` | |
 *                   | |  __/>  <| |_| |_| | (_| | |
 *                   |_|\___/_/\_\\__|\__,_|\__,_|_|
 *
 * Copyright (c) 2008 - 2010 Satoshi Nakagawa <psychs AT limechat DOT net>
 * Copyright (c) 2010 - 2018 Codeux Software, LLC & respective contributors.
 *       Please see Acknowledgements.pdf for additional information.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *  * Neither the name of Textual, "Codeux Software, LLC", nor the
 *    names of its contributors may be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *********************************************************************** */

@_objcImplementation extension TPCPreferences
{
	@objc
	class func inlineImagesMaxFilesize() -> UInt64
	{
		let filesizeTag = TPCPreferencesUserDefaults.shared().unsignedInteger(forKey: "InlineMediaMaximumFilesize")

		switch filesizeTag {
		case 1:  return 1_048_576    // 1 MB
		case 2:  return 2_097_152    // 2 MB
		case 3:  return 3_145_728    // 3 MB
		case 4:  return 4_194_304    // 4 MB
		case 5:  return 5_242_880    // 5 MB
		case 6:  return 10_485_760   // 10 MB
		case 7:  return 15_728_640   // 15 MB
		case 8:  return 20_971_520   // 20 MB
		case 9:  return 52_428_800   // 50 MB
		case 10: return 104_857_600  // 100 MB
		default: return 2_097_152    // 2 MB
		}
	}

	@objc
	class func inlineMediaMaxWidth() -> UInt
	{
		return TPCPreferencesUserDefaults.shared().unsignedInteger(forKey: "InlineMediaScalingWidth")
	}

	@objc
	class func inlineMediaMaxHeight() -> UInt
	{
		return TPCPreferencesUserDefaults.shared().unsignedInteger(forKey: "InlineMediaMaximumHeight")
	}

	@objc
	class func setInlineMediaMaxWidth(_ value: UInt)
	{
		TPCPreferencesUserDefaults.shared().setUnsignedInteger(value, forKey: "InlineMediaScalingWidth")
	}

	@objc
	class func setInlineMediaMaxHeight(_ value: UInt)
	{
		TPCPreferencesUserDefaults.shared().setUnsignedInteger(value, forKey: "InlineMediaMaximumHeight")
	}

	@objc
	class func inlineMediaLimitToBasics() -> Bool
	{
		return TPCPreferencesUserDefaults.shared().bool(forKey: "InlineMediaLimitToBasics")
	}

	@objc
	class func setInlineMediaLimitToBasics(_ value: Bool)
	{
		TPCPreferencesUserDefaults.shared().set(value, forKey: "InlineMediaLimitToBasics")
	}

	@objc
	class func inlineMediaLimitBasicsToFiles() -> Bool
	{
		return TPCPreferencesUserDefaults.shared().bool(forKey: "InlineMediaLimitBasicsToFiles")
	}

	@objc
	class func setInlineMediaLimitBasicsToFiles(_ value: Bool)
	{
		TPCPreferencesUserDefaults.shared().set(value, forKey: "InlineMediaLimitBasicsToFiles")
	}

	@objc
	class func inlineMediaLimitInsecureContent() -> Bool
	{
		return TPCPreferencesUserDefaults.shared().bool(forKey: "InlineMediaLimitInsecureContent")
	}

	@objc
	class func inlineMediaLimitNaughtyContent() -> Bool
	{
		return TPCPreferencesUserDefaults.shared().bool(forKey: "InlineMediaLimitNaughtyContent")
	}

	@objc
	class func inlineMediaLimitUnsafeContent() -> Bool
	{
		return TPCPreferencesUserDefaults.shared().bool(forKey: "InlineMediaLimitUnsafeContent")
	}

	@objc
	class func inlineMediaCheckEverything() -> Bool
	{
		return TPCPreferencesUserDefaults.shared().bool(forKey: "InlineMediaCheckEverything")
	}
}
