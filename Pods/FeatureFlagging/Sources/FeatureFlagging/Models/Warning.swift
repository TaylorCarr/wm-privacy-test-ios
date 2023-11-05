//
//  File.swift
//  
//
//  Created by Dan Esrey on 5/12/20.
//

import Foundation

public enum Warning: String, Codable {
    case CACHE_USED = "Cache was used due to remote loading failing"
    case FLAG_TYPE_NOT_SUPPORTED = "A flag with the id was found, but the type is unsupported"
    case FALLBACK_USED_REMOTE_LOAD_FAILED = "Fallback used because remote config loading failed"
    case FALLBACK_USED_FLAG_NOT_IN_REMOTE = "Fallback used because a requested flag was present in it and not the remote"
}
