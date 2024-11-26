from flask import Flask, request, jsonify
from flask_cors import CORS
import sys
import io
import traceback

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

@app.route('/execute', methods=['POST'])
def execute_code():
    try:
        # Get the code from the request
        code = request.json.get('code', '')
        
        # Redirect stdout to capture print statements
        old_stdout = sys.stdout
        redirected_output = sys.stdout = io.StringIO()
        
        try:
            # Execute the code
            exec(code)
            
            # Get the output
            output = redirected_output.getvalue()
            
            # Restore stdout
            sys.stdout = old_stdout
            
            return jsonify({
                'output': output.strip() if output else 'Code executed successfully.',
                'error': None
            })
        
        except Exception as e:
            # Restore stdout
            sys.stdout = old_stdout
            
            # Capture the full traceback
            error_message = traceback.format_exc()
            
            return jsonify({
                'output': None,
                'error': str(error_message)
            })
    
    except Exception as e:
        return jsonify({
            'output': None,
            'error': 'An unexpected error occurred: ' + str(e)
        })

if __name__ == '__main__':
    # Change to port 5001 to match the error message
    app.run(debug=True, host='0.0.0.0', port=5001)