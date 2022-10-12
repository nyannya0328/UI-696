//
//  Home.swift
//  UI-696
//
//  Created by nyannyan0328 on 2022/10/12.
//

import SwiftUI

struct Home: View {
    @State var cards : [Card] = []
    @State var EnableBlur : Bool = false
    @State var isRotatedEnaled : Bool = true
    var body: some View {
        VStack(alignment:.leading,spacing: 10){
            
            
            Toggle("EnableBlur", isOn: $EnableBlur)
            Toggle("Trun on Rotation", isOn: $isRotatedEnaled)
                .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .top)
            
            BoomerangeCard(EnableBlur: EnableBlur, isRotatedEnaled: isRotatedEnaled ,cards: $cards)
                .frame(height: 300)
                .padding(.horizontal)

            
         
            
            
        }
        .padding(15)
        .background{
         Color("BG")
                .ignoresSafeArea()
        }
        .onAppear{setupCards()}
        
        
    }
    func setupCards(){
        
        for index in 1...8{
            
            cards.append(Card(imageName: "Card \(index)"))
        }
        
        if var first = cards.first{
            first.id = UUID().uuidString
            cards.append(first)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct BoomerangeCard : View{
    var EnableBlur : Bool = false
     var isRotatedEnaled : Bool = true
    
    @Binding var cards : [Card]
    
    @State var offset : CGFloat = 0
    @State var currentIndex : Int = 0
    
    var body: some View{
        
        GeometryReader{
            
            let size = $0.size
            
            ZStack{
                
                
                ForEach(cards.reversed()){card in
                    
                    CardView(card: card, size: size)
                        .offset(y:currentIndex == indexOffset(card: card) ? offset : 0)
                }
                
                
                
            }
            .animation(.spring(response: 0.7,dampingFraction: 0.6,blendDuration: 0.6), value: offset == .zero)
            .frame(width: size.width,height: size.height)
            .contentShape(Rectangle())
            .gesture(
            
            DragGesture(minimumDistance: 2)
                .onChanged({ value in
                    
                    onChange(value: value)
                    
                })
                .onEnded({ value in
                    onEnd(value: value)
                })
            )
            
            
        }
    }
    func onChange(value : DragGesture.Value){
        
        offset = currentIndex == (cards.count - 1) ? 0 : value.translation.height
        
        
    }
    func onEnd(value : DragGesture.Value){
        
        var translation = value.translation.height
        
        translation = (translation < 0 ? -translation : 0)
        translation = (currentIndex == (cards.count - 1) ? 0 : translation)
        
        
        if translation > 110{
            
            withAnimation(.interactiveSpring(response: 0.5,dampingFraction: 0.8,blendDuration: 0.7)){
             
                
                
                cards[currentIndex].isRotated = true
                
                cards[currentIndex].extractOffset = -350
                cards[currentIndex].scale = 0.7
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                
                withAnimation(.interactiveSpring(response: 0.5,dampingFraction: 0.8,blendDuration: 0.7)){
                    
                    cards[currentIndex].zindex = -100
                    for index in cards.indices{
                        
                        cards[index].extractOffset = 0
                    }
                    
                    if currentIndex != (cards.count - 1){
                        
                        currentIndex += 1
                    }
                    
                    offset = .zero
                    
                }
                
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                
                
                for index in cards.indices{
                    
                    if index == currentIndex{
                        
                        if cards.indices.contains(currentIndex - 1){
                            
                            cards[currentIndex - 1].zindex = ZIndex(card: cards[currentIndex - 1])
                            
                            
                        }
                        
                    }
                    else{
                        
                        cards[index].isRotated = false
                        withAnimation(.linear){
                            
                            cards[index].scale = 1
                        }
                        
                    }
                    
                }
                
                if currentIndex == (cards.count - 1){
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25){
                        
                        
                        for index in cards.indices{
                            
                            cards[index].zindex = 0
                        }
                        currentIndex = 0
                        
                    }
                    
                }
                
                
                
            }
            
            
        }
        else{
            
            offset = .zero
            
            
        }
       
        
    
        
        
    }
    func ZIndex(card : Card) -> Double{
        
        let index = indexOffset(card: card)
        
        let totalCount = cards.count
        
        return currentIndex > index ? Double(index - totalCount) : cards[index].zindex
    }
    @ViewBuilder
    func CardView(card : Card,size : CGSize)->some View{
        
        
        let index = indexOffset(card: card)
        
        Image(card.imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width,height: size.height)
            .blur(radius: card.isRotated && EnableBlur ? 65 : 0)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .scaleEffect(card.scale,anchor: card.isRotated ? .center : .top)
            .rotation3DEffect(.init(degrees: isRotatedEnaled && card.isRotated ? 360 : 0), axis: (x: 0, y: 0, z: 1))
            .offset(y:-offsetFor(index: index))
            .offset(y:card.extractOffset)
            .scaleEffect(scaleFor(index: index),anchor: .top)
            .zIndex(card.zindex)
        
    }
    
    func scaleFor(index value : Int)->Double{
        
        let index = Double(value - currentIndex)
        
        if index >= 0{
            
            if index > 3{
                
                return 0.8
                
            }
            
            return 1 - (index / 15)
        }
        
        else{
            
            if -index > 3{
                
                return 0.8
                
            }
            return 1 + (index / 15)
            
            
            
        }
    }
    
    func offsetFor(index value : Int)->Double{
        
        let index = Double(value - currentIndex)
        
        if index >= 0{
            
            
            if index > 3{
                
                return 30
            }
            
            return (index * 10)
            
            
            
        }
        else{
            
            
            if -index > 3{
                
                
                return 30
            }
            
            return (-index * 30)
        }
    }
    
    func indexOffset(card : Card)->Int{
        
        if let index = cards.firstIndex(where: { CAA in
            CAA.id == card.id
        }){
            
            return index
        }
        
        return 0
        
        
    }

}
