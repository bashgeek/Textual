/* *********************************************************************
 *                  _____         _               _
 *                 |_   _|____  _| |_ _   _  __ _| |
 *                   | |/ _ \ \/ / __| | | |/ _` | |
 *                   | |  __/>  <| |_| |_| | (_| | |
 *                   |_|\___/_/\_\\__|\__,_|\__,_|_|
 *
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

import CoreData
import Foundation

/* TVCLogLineXPC is a container class for TVCLogLine when stored in a
 Core Data store. -data is the secure coded version of the class which is
 portable and can be stored in an offline database. */
@objc(TVCLogLineXPC)
final class TVCLogLineXPC: NSObject, NSSecureCoding, @unchecked Sendable
{
	@objc private(set) var data: Data = Data()
	@objc private(set) var uniqueIdentifier: String = ""
	@objc private(set) var viewIdentifier: String = ""
	@objc private(set) var sessionIdentifier: UInt = 0
	@objc private(set) var creationDate: TimeInterval = 0

	@objc
	init(logLineData data: Data, uniqueIdentifier: String, viewIdentifier: String, sessionIdentifier: UInt)
	{
		self.data = data
		self.uniqueIdentifier = uniqueIdentifier
		self.viewIdentifier = viewIdentifier
		self.sessionIdentifier = sessionIdentifier
	}

	@objc
	init(managedObject: NSManagedObject)
	{
		data = (managedObject.value(forKey: "logLineData") as? Data) ?? Data()
		uniqueIdentifier = (managedObject.value(forKey: "logLineUniqueIdentifier") as? String) ?? ""
		viewIdentifier = (managedObject.value(forKey: "logLineViewIdentifier") as? String) ?? ""
		sessionIdentifier = UInt((managedObject.value(forKey: "sessionIdentifier") as? Int) ?? 0)
		creationDate = (managedObject.value(forKey: "entryCreationDate") as? Double) ?? 0
	}

	@objc required
	init?(coder aDecoder: NSCoder)
	{
		data = aDecoder.decodeData(forKey: "data") ?? Data()
		uniqueIdentifier = aDecoder.decodeString(forKey: "uniqueIdentifier") ?? ""
		viewIdentifier = aDecoder.decodeString(forKey: "viewIdentifier") ?? ""
		sessionIdentifier = UInt(aDecoder.decodeInteger(forKey: "sessionIdentifier"))
		creationDate = aDecoder.decodeDouble(forKey: "entryCreationDate")
	}

	@objc
	func encode(with aCoder: NSCoder)
	{
		aCoder.encode(data, forKey: "data")
		aCoder.encode(uniqueIdentifier, forKey: "uniqueIdentifier")
		aCoder.encode(viewIdentifier, forKey: "viewIdentifier")
		aCoder.encode(Int(sessionIdentifier), forKey: "sessionIdentifier")
		aCoder.encode(creationDate, forKey: "entryCreationDate")
	}

	@objc static let supportsSecureCoding: Bool = true

	override var description: String
	{
		return "<TVCLogLineXPC \(uniqueIdentifier) - \(creationDate)>"
	}
}
