import Model
import SwiftUI

struct ContentView: View {
    @ObservedObject var model: Model

    var body: some View {
        VStack(spacing: 40) {
            Text("Row creation test").font(.title)

            VStack(spacing: 20) {
                HStack {
                    Text("\(model.rows.count)")
                    Spacer()
                    Text("\(model.rowCountMaximum)")
                }
                ProgressView(value: model.progress)
                    .progressViewStyle(LinearProgressViewStyle())
                if model.canStart {
                    Text("Not running")
                } else {
                    Text("Running")
                }
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 4).stroke().foregroundColor(Color.orange))

            HStack {
                Button {
                    model.start()
                } label: {
                    Text("Run test")
                        .foregroundColor(Color.white)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 80)
                        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.accentColor))
                }
                .disabled(!model.canStart)
                .padding(10)
            }
        }
        .padding(40)
    }
}

struct ContentView_Previews: PreviewProvider {
    @StateObject static var model = Model()

    static var previews: some View {
        ContentView(model: model)
    }
}
