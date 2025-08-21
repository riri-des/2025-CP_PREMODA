"""
Virtual Try-On Backend Server
This is an example implementation showing how to create a backend API
for realistic virtual try-on using deep learning models.
"""

import os
import io
import uuid
import logging
from datetime import datetime
from flask import Flask, request, jsonify, send_file, url_for
from flask_cors import CORS
from PIL import Image
import numpy as np
import torch
import torchvision.transforms as transforms
from werkzeug.utils import secure_filename

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# Configuration
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['RESULTS_FOLDER'] = 'results'
app.config['ALLOWED_EXTENSIONS'] = {'png', 'jpg', 'jpeg', 'gif'}

# Create necessary directories
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
os.makedirs(app.config['RESULTS_FOLDER'], exist_ok=True)

# Initialize your VTON model here
# This is where you would load a pre-trained CP-VTON or similar model
class VTONModel:
    """
    Placeholder for the actual VTON model.
    In production, this would load a real deep learning model.
    """
    def __init__(self):
        # Load your model weights here
        # self.model = load_cpvton_model()
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        logger.info(f"Using device: {self.device}")
        
    def process(self, person_image, clothing_image, clothing_type):
        """
        Process the virtual try-on.
        In production, this would run the actual deep learning inference.
        """
        # For demonstration, we'll just return a processed version
        # In reality, this would:
        # 1. Extract pose from person image
        # 2. Segment the person
        # 3. Warp the clothing to fit the person's pose
        # 4. Blend the warped clothing onto the person
        
        # Placeholder processing
        logger.info(f"Processing virtual try-on for {clothing_type}")
        
        # Here you would implement the actual VTON algorithm
        # For now, we'll add a visible overlay to show it's processed
        from PIL import ImageDraw, ImageFont
        
        result = person_image.copy()
        draw = ImageDraw.Draw(result)
        
        # Add a more visible overlay to indicate processing
        # Draw a large red rectangle with text
        width, height = result.size
        rect_height = 100
        draw.rectangle([(0, 0), (width, rect_height)], fill=(255, 0, 0, 180))
        
        # Add text in white
        text = f"BACKEND PROCESSED: {clothing_type.upper()}"
        try:
            # Try to use a larger font if available
            font = ImageFont.truetype("arial.ttf", 36)
        except:
            font = None  # Use default font
        
        text_bbox = draw.textbbox((0, 0), text, font=font)
        text_width = text_bbox[2] - text_bbox[0]
        text_height = text_bbox[3] - text_bbox[1]
        text_x = (width - text_width) // 2
        text_y = (rect_height - text_height) // 2
        
        draw.text((text_x, text_y), text, fill=(255, 255, 255), font=font)
        draw.text((10, rect_height + 10), f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", fill=(255, 0, 0))
        
        return result

# Initialize model
vton_model = VTONModel()

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in app.config['ALLOWED_EXTENSIONS']

@app.route('/api/virtual-tryon', methods=['POST'])
def virtual_tryon():
    """
    Main endpoint for virtual try-on processing.
    Expects:
    - person_image: Image file of the person
    - clothing_image_path: Path to clothing image (optional)
    - clothing_name: Name of the clothing item
    - clothing_type: Type of clothing (dress, polo, tshirt)
    - clothing_color: Color in hex format
    - clothing_size: Size (S, M, L, XL, etc.)
    """
    try:
        # Validate request
        if 'person_image' not in request.files:
            return jsonify({'success': False, 'error': 'No person image provided'}), 400
        
        person_file = request.files['person_image']
        if person_file.filename == '':
            return jsonify({'success': False, 'error': 'No person image selected'}), 400
        
        if not allowed_file(person_file.filename):
            return jsonify({'success': False, 'error': 'Invalid file type'}), 400
        
        # Get metadata
        clothing_name = request.form.get('clothing_name', 'Unknown')
        clothing_type = request.form.get('clothing_type', 'unknown')
        clothing_color = request.form.get('clothing_color', '#000000')
        clothing_size = request.form.get('clothing_size', 'M')
        
        logger.info(f"Processing request for {clothing_name} ({clothing_type})")
        
        # Save uploaded person image
        person_filename = secure_filename(f"person_{uuid.uuid4().hex}_{person_file.filename}")
        person_path = os.path.join(app.config['UPLOAD_FOLDER'], person_filename)
        person_file.save(person_path)
        
        # Load person image
        person_image = Image.open(person_path).convert('RGB')
        
        # Load or generate clothing image
        clothing_image = None
        if 'clothing_image' in request.files:
            clothing_file = request.files['clothing_image']
            if clothing_file and allowed_file(clothing_file.filename):
                clothing_filename = secure_filename(f"cloth_{uuid.uuid4().hex}_{clothing_file.filename}")
                clothing_path = os.path.join(app.config['UPLOAD_FOLDER'], clothing_filename)
                clothing_file.save(clothing_path)
                clothing_image = Image.open(clothing_path).convert('RGB')
        else:
            # Generate a placeholder clothing image based on type and color
            # In production, you might have a database of clothing items
            clothing_image = generate_clothing_placeholder(clothing_type, clothing_color)
        
        # Process virtual try-on
        result_image = vton_model.process(person_image, clothing_image, clothing_type)
        
        # Save result
        result_filename = f"result_{uuid.uuid4().hex}.jpg"
        result_path = os.path.join(app.config['RESULTS_FOLDER'], result_filename)
        result_image.save(result_path, 'JPEG', quality=95)
        
        # Generate URL for the result
        # In production, you'd serve these through a CDN or static file server
        result_url = url_for('get_result', filename=result_filename, _external=True)
        
        # Clean up uploaded files
        os.remove(person_path)
        if clothing_image and 'clothing_image' in request.files:
            os.remove(clothing_path)
        
        return jsonify({
            'success': True,
            'result_image_url': result_url,
            'message': 'Virtual try-on completed successfully'
        })
        
    except Exception as e:
        logger.error(f"Error processing virtual try-on: {str(e)}")
        return jsonify({
            'success': False,
            'error': f'Processing error: {str(e)}'
        }), 500

@app.route('/api/results/<filename>')
def get_result(filename):
    """Serve result images."""
    try:
        return send_file(
            os.path.join(app.config['RESULTS_FOLDER'], filename),
            mimetype='image/jpeg'
        )
    except FileNotFoundError:
        return jsonify({'error': 'Result not found'}), 404

@app.route('/')
def index():
    """Root endpoint - API information."""
    return jsonify({
        'name': 'Virtual Try-On Backend API',
        'version': '1.0.0',
        'endpoints': {
            'POST /api/virtual-tryon': 'Process virtual try-on request',
            'GET /api/results/<filename>': 'Retrieve processed result image',
            'GET /api/health': 'Health check endpoint'
        },
        'status': 'running',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint."""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'device': str(vton_model.device)
    })

def generate_clothing_placeholder(clothing_type, color_hex):
    """
    Generate a simple placeholder clothing image.
    In production, you would have actual clothing images in a database.
    """
    # Create a simple colored rectangle as placeholder
    width, height = 512, 512
    
    # Convert hex color to RGB
    color_hex = color_hex.lstrip('#')
    rgb = tuple(int(color_hex[i:i+2], 16) for i in (0, 2, 4))
    
    # Create image
    image = Image.new('RGB', (width, height), color=rgb)
    
    # Add some text to indicate clothing type
    from PIL import ImageDraw, ImageFont
    draw = ImageDraw.Draw(image)
    text = f"{clothing_type.upper()}"
    
    # Calculate text position (centered)
    text_bbox = draw.textbbox((0, 0), text)
    text_width = text_bbox[2] - text_bbox[0]
    text_height = text_bbox[3] - text_bbox[1]
    x = (width - text_width) // 2
    y = (height - text_height) // 2
    
    draw.text((x, y), text, fill=(255, 255, 255))
    
    return image

if __name__ == '__main__':
    # Run the server
    # In production, use a proper WSGI server like Gunicorn
    app.run(host='0.0.0.0', port=8000, debug=True)
