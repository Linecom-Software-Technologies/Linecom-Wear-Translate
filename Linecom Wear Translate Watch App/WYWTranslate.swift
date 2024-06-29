//
//  WYWTranslate.swift
//  Linecom Wear Translate Watch App
//
//  Created by 澪空 on 2024/6/28.
//

import SwiftUI
import DarockKit

struct WYWTranslate: View {
    var body: some View{
        TabView{
            WYWToCN()
        }
    }
    
    struct WYWToCN: View {
        @State var wywin=""
        @State var wywout=""
        @State var req=false
        var body: some View {
            List{
                Section{
                    HStack{
                        Spacer()
                        Text("文言->中文")
                        Spacer()
                    }
                }
                Section{
                    TextField("输入文言", text: $wywin)
                    Button(action: {
                        req=true
                        if !wywin.isEmpty{
                            DarockKit.Network.shared.requestJSON("https://api.linecom.net.cn/lwt/translate?provider=baidu&text=\(wywin)&slang=wyw&tlang=zh&pass=l1nec0m".urlEncoded()){
                                resp, successd in
                                wywout=resp["trans_result"][0]["dst"].string ?? "返回错误"
                            }
                        } else {
                            wywout="请输入文本"
                        }
                        req=false
                    }, label: {
                        if !req{
                            HStack{
                                Spacer()
                                Text("翻译")
                                Spacer()
                            }
                        } else {
                            ProgressView()
                        }
                    })
                }
                if !wywout.isEmpty{
                    Section{
                        Text(wywout)
                        Button(action: {
                            wywin=""
                        }, label: {
                            Text("重置")
                        })
                    }
                }
                
            }
        }
    }
}

#Preview {
    WYWTranslate()
}
