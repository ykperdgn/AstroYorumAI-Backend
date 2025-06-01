#!/usr/bin/env python3
"""
Simple flatlib test
"""
try:
    from flatlib.datetime import Datetime
    from flatlib.geopos import GeoPos
    from flatlib.chart import Chart
    from flatlib import const
    
    print("SUCCESS: Flatlib imports successful")
    
    # Create datetime (flatlib format: 'YYYY/MM/DD', 'HH:MM', timezone)
    dt = Datetime('1990/01/15', '14:30', '+00:00')
    print(f"DateTime created: {dt}")
    
    # Create position (flatlib format: lat/lon as strings with degrees:minutes:seconds)
    pos = GeoPos('+40:42:46', '-74:00:21')  # New York coordinates
    print(f"Position created: {pos}")
    
    # Create chart
    chart = Chart(dt, pos)
    print("Chart created successfully")
    
    # Get Sun position
    sun = chart.get(const.SUN)
    print(f"Sun: {sun.sign} at {sun.signlon:.2f} degrees")
    
    # Get Moon position
    moon = chart.get(const.MOON)
    print(f"Moon: {moon.sign} at {moon.signlon:.2f} degrees")
    
    print("SUCCESS: Flatlib is working correctly!")
    
except Exception as e:
    print(f"ERROR: {e}")
    import traceback
    traceback.print_exc()
