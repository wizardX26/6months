import Foundation

protocol ContainerLayoutParticipant: AnyObject {
    func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: LayoutTransition)
}
