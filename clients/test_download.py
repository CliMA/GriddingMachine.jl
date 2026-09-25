import hashlib, http.server, os, subprocess, tempfile, threading, unittest
from pathlib import Path

ROOT=Path(__file__).parent
class T(unittest.TestCase):
  def test_download_and_hash(self):
    with tempfile.TemporaryDirectory() as d:
      root=Path(d); payload=b'griddingmachine-test'; (root/'x.nc').write_bytes(payload)
      h=http.server.ThreadingHTTPServer(('127.0.0.1',0),lambda *a,**k:http.server.SimpleHTTPRequestHandler(*a,directory=d,**k))
      t=threading.Thread(target=h.serve_forever,daemon=True); t.start()
      out=root/'out.nc'; url=f'http://127.0.0.1:{h.server_port}/x.nc'
      subprocess.check_call(['python3',str(ROOT/'download.py'),'--url',url,'--output',str(out),'--size',str(len(payload)),'--sha256',hashlib.sha256(payload).hexdigest()])
      self.assertEqual(out.read_bytes(),payload); h.shutdown()
if __name__=='__main__': unittest.main()
