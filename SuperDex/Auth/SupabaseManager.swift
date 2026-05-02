//
//  SupabaseManager.swift
//  SuperDex
//

import Foundation
import Supabase

enum SupabaseConfig {
    static let url = URL(string: "https://krgighgbudwalorlbsrs.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtyZ2lnaGdidWR3YWxvcmxic3JzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY0NDMzNTEsImV4cCI6MjA5MjAxOTM1MX0.hd1Lbgw7zhKfVJYK-dTii23NvPNSa6Wgji9mTLXeX_0"
}

enum SupabaseManager {
    static let client = SupabaseClient(
        supabaseURL: SupabaseConfig.url,
        supabaseKey: SupabaseConfig.anonKey
    )
}
