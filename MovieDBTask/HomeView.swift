//
//  ContentView.swift
//  MovieDBTask
//
//  Created by Barath K on 13/05/22.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0 //selected page
    let dataModel = ["Popular", "Top Rating"]
    
    var body: some View {
        if #available(iOS 14.0, *) {
            VStack {
                //ScrollableTabView
                ScrollView(.horizontal, showsIndicators: false, content: {
                    ScrollViewReader { scrollReader in
                        ScrollableTabView(activeIdx: $selection,dataSet: dataModel)
                            .padding(.top).onChange(of: selection, perform: { value in
                                withAnimation{
                                    scrollReader.scrollTo(value, anchor: .center)
                                }
                            })
                    }
                })
                //Page View
                LazyHStack {
                    PageView(selection: $selection, dataModel: dataModel)
                }
            }.onChange(of: selection, perform: { value in
             
            })
        } else {
            // Fallback on earlier versions
        }
    }
}
struct PageView: View {
    @Binding var selection: Int
    let dataModel: [String]
    var body: some View {
        if #available(iOS 14.0, *) {
            TabView(selection:$selection) {
                ForEach(0..<dataModel.count) { i in
                    VStack {
                        HStack {
                            ContentView1(selection: $selection)
                        }
                    }.tag(i)
                }
            }
            .frame(width: UIScreen.main.bounds.width)
            .tabViewStyle(PageTabViewStyle.init(indexDisplayMode: .never))
        } else {
            // Fallback on earlier versions
        }
        
    }
}

//Tab bar

extension HorizontalAlignment {
    private enum UnderlineLeading: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            return d[.leading]
        }
    }
    
    static let underlineLeading = HorizontalAlignment(UnderlineLeading.self)
}

struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue = CGFloat(0)
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
    
    typealias Value = CGFloat
}


struct ScrollableTabView : View {
    
    @Binding var activeIdx: Int
    @State private var w: [CGFloat]
    private let dataSet: [String]
    init(activeIdx: Binding<Int>, dataSet: [String]) {
        self._activeIdx = activeIdx
        self.dataSet = dataSet
        _w = State.init(initialValue: [CGFloat](repeating: 0, count: dataSet.count))
    }
    
    var body: some View {
        VStack(alignment: .underlineLeading) {
            HStack {
                ForEach(0..<dataSet.count) { i in
                    Text(dataSet[i])
                        .font(Font.title.bold())
                        .modifier(ScrollableTabViewModifier(activeIdx: $activeIdx, idx: i))
                        .background(TextGeometry())
                        .onPreferenceChange(WidthPreferenceKey.self, perform: { self.w[i] = $0 })
                        .id(i)
                    Spacer().frame(width: 20)
                }
            }
            .padding(.horizontal, 5)
            Rectangle()
                .alignmentGuide(.underlineLeading) { d in d[.leading]  }
                .frame(width: w[activeIdx],  height: 4)
                .animation(.linear)
        }
    }
}

struct TextGeometry: View {
    var body: some View {
        GeometryReader { geometry in
            return Rectangle().fill(Color.clear).preference(key: WidthPreferenceKey.self, value: geometry.size.width)
        }
    }
}

struct ScrollableTabViewModifier: ViewModifier {
    @Binding var activeIdx: Int
    let idx: Int
    
    func body(content: Content) -> some View {
        Group {
            if activeIdx == idx {
                content.alignmentGuide(.underlineLeading) { d in
                    return d[.leading]
                }.onTapGesture {
                    withAnimation{
                        self.activeIdx = self.idx
                    }
                }
                
            } else {
                content.onTapGesture {
                    withAnimation{
                        self.activeIdx = self.idx
                    }
                }
            }
        }
    }
}

struct ContentView1: View {
    
    @ObservedObject var viewModel: MovieViewModel = MovieViewModel()
    @State var isNavigate = false
    @Binding var selection: Int
    var body: some View {
        GeometryReader{ geometry in
            CustomScrollView(width: geometry.size.width, height: geometry.size.height, handlePullToRefresh: {
                self.pullToRefresh()
            }) {
                SwiftUIList(model: self.viewModel, isNavigate: $isNavigate)
                    .background(SwiftUI.Color.white)
            }
        }.onAppear {
            viewModel.movies = []
            viewModel.getMovies(selection) {
                
            }
        }
    }
    
    private func pullToRefresh() {
        viewModel.refreshFeeds(selection) {
            
        }
    }
}

struct SwiftUIList: View {
    @ObservedObject var model: MovieViewModel
    @Binding var isNavigate: Bool
    var body: some View {
       
        if #available(iOS 14.0, *) {
            List(model.movies) { movie in
                VStack(alignment: .leading) {
                    URLImageView(urlString: baseUrlForImage + movie.imagePath)
                    Text(movie.title)
                        .lineLimit(nil)
                        .font(.headline)
                    Text(CommonMethods.changeDateFormate(strDate: movie.date) ?? "")
                        .font(.subheadline)
                        .onAppear {
                            //                        self.listFeedItemAppears(movie)
                        }
                }
            }.listStyle(SidebarListStyle())
            .background(SwiftUI.Color.white)
            .padding(.bottom,40)
            .onAppear(perform: {
                self.setupMethod()
            })
            .onTapGesture {
                self.isNavigate = true
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func setupMethod() {
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
        UITableView.appearance().contentInset.top = -60
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UITableView.appearance().contentInset.top = 0
        }
    }
}

struct CustomScrollView<ROOTVIEW>: UIViewRepresentable where ROOTVIEW: View {
    
    var width : CGFloat, height : CGFloat
    let handlePullToRefresh: () -> Void
    let rootView: () -> ROOTVIEW
    
    func makeCoordinator() -> Coordinator<ROOTVIEW> {
        Coordinator(self, rootView: rootView, handlePullToRefresh: handlePullToRefresh)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let control = UIScrollView()
        control.refreshControl = UIRefreshControl()
        control.refreshControl?.addTarget(context.coordinator, action:
            #selector(Coordinator.handleRefreshControl),
                                          for: .valueChanged)

        let childView = UIHostingController(rootView: rootView() )
        childView.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        control.addSubview(childView.view)
        return control
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {}

    class Coordinator<ROOTVIEW>: NSObject where ROOTVIEW: View {
        var control: CustomScrollView
        var handlePullToRefresh: () -> Void
        var rootView: () -> ROOTVIEW

        init(_ control: CustomScrollView, rootView: @escaping () -> ROOTVIEW, handlePullToRefresh: @escaping () -> Void) {
            self.control = control
            self.handlePullToRefresh = handlePullToRefresh
            self.rootView = rootView
        }

        @objc func handleRefreshControl(sender: UIRefreshControl) {
            sender.endRefreshing()
            handlePullToRefresh()
        }
    }
}
