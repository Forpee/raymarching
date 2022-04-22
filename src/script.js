import './style.css'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import * as dat from 'dat.gui'
import vertexShader from './shaders/vertex.glsl'
import fragmentShader from './shaders/fragment.glsl'
import gsap from 'gsap'
/**
 * Base
 */
// Debug
let settings = {
    progress: 0.0
}

const gui = new dat.GUI()
gui.add(settings, 'progress').min(0.0).max(1.0).step(0.01).onChange(() => {
    material.uniforms.progress.value = settings.progress
})

// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()

/**
 * Test mesh
 */
// Geometry
const geometry = new THREE.PlaneBufferGeometry(1, 1, 32, 32)
let mouse = new THREE.Vector2(0, 0)

// Material
const material = new THREE.ShaderMaterial({
    uniforms: {
        uTime: { value: 0 },
        progress : { value: 0 },
        mouse: { value: new THREE.Vector2(0, 0) },
        uMatcap: { value: new THREE.TextureLoader().load('/matcap.png') }
    },
    vertexShader: vertexShader,
    fragmentShader: fragmentShader,
    side: THREE.DoubleSide
})

document.addEventListener('mousemove', (event) => {
    // mouse.x = e.clientX / window.innerWidth - 0.5
    // mouse.y = -e.clientY / window.innerHeight + 0.5

    mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
    mouse.y = - (event.clientY / window.innerHeight) * 2 + 1;
    // console.log(mouse.x, mouse.y)
})

// Mesh
const mesh = new THREE.Mesh(geometry, material)
scene.add(mesh)

/**
 * Sizes
 */
const sizes = {
    width: window.innerWidth,
    height: window.innerHeight
}

window.addEventListener('resize', () => {
    // Update sizes
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight

    // Update camera
    camera.aspect = sizes.width / sizes.height
    camera.updateProjectionMatrix()

    // Update renderer
    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})

/**
 * Camera
 */
// Orthographic camera
const camera = new THREE.OrthographicCamera(-1 / 2, 1 / 2, 1 / 2, -1 / 2, 0.1, 100)

// Base camera
// const camera = new THREE.PerspectiveCamera(75, sizes.width / sizes.height, 0.1, 100)
camera.position.set(0, 0, 2)
scene.add(camera)

// Controls
const controls = new OrbitControls(camera, canvas)
controls.enableDamping = true

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
    canvas: canvas
})
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

/**
 * Animate
 */
const clock = new THREE.Clock()

const tick = () => {
    // Update controls
    controls.update()

    // Get elapsedtime
    const elapsedTime = clock.getElapsedTime()

    // Update uniforms
    material.uniforms.uTime.value = elapsedTime
    if (mouse) {
        material.uniforms.mouse.value = mouse;

    }
    // Render
    renderer.render(scene, camera)

    // Call tick again on the next frame
    window.requestAnimationFrame(tick)
}

tick()