package com.wudsn.tst;

import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.image.BufferedImage;

import javax.swing.ImageIcon;
import javax.swing.JFrame;
import javax.swing.JLabel;

public final class Abbuc99Bounce {

    /**
     * @param args
     */
    public static void main(String[] args) {
	Abbuc99Bounce instance = new Abbuc99Bounce();

	JFrame f = new JFrame("ImageDrawing");
	f.addWindowListener(new WindowAdapter() {
	    @Override
	    public void windowClosing(WindowEvent e) {
		System.exit(0);
	    }
	});
	
	BufferedImage bi = new BufferedImage(768, 256,
		BufferedImage.TYPE_INT_RGB);

	ImageIcon imageIcon = new ImageIcon();
	imageIcon.setImage(bi);
	JLabel label = new JLabel();
	label.setIcon(imageIcon);

	f.add("Center", label);
	f.pack();
	f.setVisible(true);

	StringBuilder builder = new StringBuilder();
	instance.test(bi, builder);
	System.out.println(builder.toString());

	imageIcon.setImage(bi);
	label.setIcon(imageIcon);
	label.repaint();

	try {
	    Thread.sleep(0);
	} catch (InterruptedException ex) {
	    // TODO Auto-generated catch block
	    ex.printStackTrace();
	}
    }

    private void test(BufferedImage bi, StringBuilder builder) {
	if (bi == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'bi' must not be null.");
	}
	int top = 255;
	double dy = 0;
	double energy = 255;
	double speed = -0.5;
	double acceleration = -0.185;
	double elastic = 0.5;
	for (int x = 0; x < 255; x++) {
	    energy = energy + speed;
	    speed = speed + acceleration;
//	    speed = speed*0.999;
	    if (energy < 0) {
		energy = -energy;
		speed = -speed;
//		acceleration= acceleration - 0.01;
		if (speed > 1) {

		    speed = speed * elastic;
		} else {
		    speed = 0;

		}
	    }

	    dy = energy;
	    int y = (int) dy;
	    try {
		bi.setRGB(x, top - y, 0xffffff);
	    } catch (Exception ex) {
		// TODO: handle exception
	    }
	    if (x % 64 == 0) {
		builder.append("\n\t.byte ");
	    }
	    builder.append(y);
	    if (x % 64 < 63) {
		builder.append(",");
	    }

	    dy = 128 + speed * 10;
	    y = (int) dy;
	    try {
		bi.setRGB(x, top - y, 0xff00000);
	    } catch (Exception ex) {
		// TODO: handle exception
	    }
	    dy = 128 + acceleration * 100;
	    y = (int) dy;
	    try {
		bi.setRGB(x, top - y, 0x00ff00);
	    } catch (Exception ex) {
		// TODO: handle exception
	    }
	}
    }

}
