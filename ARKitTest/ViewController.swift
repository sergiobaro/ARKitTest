
import UIKit
import ARKit

class ViewController: UIViewController {

    let arView = ARSCNView()
    let configuration = ARWorldTrackingConfiguration()
    let plusButton = UIButton()
    let resetButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        sessionConfiguration()
        
        arView.delegate = self
    }

    private func configureView() {
        view.addSubview(arView)
        arView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(plusButton)
        plusButton.layer.cornerRadius = 25
        plusButton.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.addTarget(self, action: #selector(plusButtonTap), for: .touchUpInside)
        NSLayoutConstraint.activate([
            plusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            plusButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            plusButton.widthAnchor.constraint(equalToConstant: 50),
            plusButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        view.addSubview(resetButton)
        resetButton.layer.cornerRadius = 25
        resetButton.backgroundColor = UIColor.red.withAlphaComponent(0.7)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.addTarget(self, action: #selector(resetButtonTap), for: .touchUpInside)
        NSLayoutConstraint.activate([
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            resetButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            resetButton.widthAnchor.constraint(equalToConstant: 50),
            resetButton.heightAnchor.constraint(equalToConstant: 50)
            
        ])
    }
    
    private func sessionConfiguration() {
        configuration.planeDetection = .horizontal
        arView.session.run(configuration, options: [])
        arView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        arView.autoenablesDefaultLighting = true
    }
    
    @objc private func plusButtonTap() {
//        addBox()
//        addPyramid()
//        draw3DModel()
        drawEarth()
    }
    
    @objc private func resetButtonTap() {
        arView.session.pause()
        arView.scene.rootNode.enumerateChildNodes { node, _ in
            node.removeFromParentNode()
        }
        arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    private func addBox() {
        let box = SCNNode()
        box.geometry = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0.01)
        box.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        box.position = SCNVector3(-0.05,-0.05,0)
        arView.scene.rootNode.addChildNode(box)
    }
    
    private func addPyramid() {
        let pyramid = SCNNode()
        pyramid.geometry = SCNPyramid(width: 0.05, height: 0.07, length: 0.04)
        pyramid.geometry?.firstMaterial?.diffuse.contents = UIColor.green.withAlphaComponent(0.9)
        pyramid.position = SCNVector3(0,0,0)
        
        let rotate = CABasicAnimation(keyPath: "eulerAngles.y")
        rotate.fromValue = 0
        rotate.toValue = 2 * CGFloat.pi
        rotate.duration = 1.2
        rotate.fillMode = .forwards
        rotate.repeatCount = .infinity
        rotate.isRemovedOnCompletion = false
        
        pyramid.addAnimation(rotate, forKey: "rotate")
        
        arView.scene.rootNode.addChildNode(pyramid)
    }
    
    private func draw3DModel() {
        let node = SCNNode()
        let name = "art.scnassets/phoenix.usdz"
        
        guard let modelScene = SCNScene(named: name) else { return }
        for child in modelScene.rootNode.childNodes {
            node.addChildNode(child)
        }
        
        node.scale = SCNVector3(0.0003, 0.0003, 0.0003)
        node.position = SCNVector3(-0.1, -0.1, 0)
        node.eulerAngles = SCNVector3(0, -CGFloat.pi, 0)
        
        arView.scene.rootNode.addChildNode(node)
    }
    
    private func drawEarth() {
        let node = SCNNode()
        node.geometry = SCNSphere(radius: 0.2)
        node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "earthDiffuse")
        node.geometry?.firstMaterial?.specular.contents = UIImage(named: "earthSpecular")
        node.geometry?.firstMaterial?.emission.contents = UIImage(named: "earthEmission")
        node.geometry?.firstMaterial?.normal.contents = UIImage(named: "earthNormal")
        
        let rotate = CABasicAnimation(keyPath: "eulerAngles.y")
        rotate.fromValue = 0
        rotate.toValue = 2 * CGFloat.pi
        rotate.duration = 10.0
        rotate.fillMode = .forwards
        rotate.repeatCount = .infinity
        rotate.isRemovedOnCompletion = false
        
        node.addAnimation(rotate, forKey: "rotate")
        
        node.position = SCNVector3(0,0,-0.5)
        arView.scene.rootNode.addChildNode(node)
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        print("Plane detected: \(planeAnchor)")
    }
}
