package com.wudsn.tst;

import java.awt.Graphics;
import java.awt.Image;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.image.BufferedImage;

import javax.swing.ImageIcon;
import javax.swing.JFrame;
import javax.swing.JLabel;

public final class Abbuc99Text {

    /**
     * @param args
     */
    public static void main(String[] args) {
	Abbuc99Text instance = new Abbuc99Text();

	JFrame f = new JFrame("ImageDrawing");
	f.addWindowListener(new WindowAdapter() {
	    @Override
	    public void windowClosing(WindowEvent e) {
		System.exit(0);
	    }
	});

	ImageIcon icon = new ImageIcon(
		"C:/Documents and Settings/d025328/My Documents/Eclipse/workspace.jac/Test/src/com/wudsn/tst/Abbuc99Text.png");
	Image image = icon.getImage();

	// Create empty BufferedImage, sized to Image
	BufferedImage bi = new BufferedImage(image.getWidth(null), image
		.getHeight(null), BufferedImage.TYPE_INT_ARGB);

	// Draw Image into BufferedImage
	Graphics g = bi.getGraphics();
	g.drawImage(image, 0, 0, null);

	ImageIcon imageIcon = new ImageIcon();
	imageIcon.setImage(bi);
	JLabel label = new JLabel();
	label.setIcon(imageIcon);

	f.add("Center", label);
	f.pack();
	f.setVisible(true);

	StringBuilder builder = new StringBuilder();
	instance.test(bi, builder);
	label.repaint();

	System.out.println(builder.toString());

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
	int y2 = 7;
	for (int y = -16; y < 270; y++) {
	    double b=0.11;
	    double a = -0.50 + 7.5d * (y + y2) / 256d+b;
	    double a2 = +0.25 + 18.5d * (y + y2) / 256d+b;
	    double dx = 56 + 48 * Math.sin(a);
	    double dx2 = 32 + 28.5 * Math.sin(a2);
	    int x = (int) (dx + dx2)-22;

		for (int i = 0; i < 8 * 16; i++) {
		    for (int j = 0; j < 7; j++) {
			    try {
			bi.setRGB(x + i+40, y + j, 0x001100*j);
			    } catch (Exception ex) {
				// TODO: handle exception
			    }
		    }
		}
	
	    if (y % 32 == 0) {
		builder.append("\n\t.byte ");
	    }
	    builder.append(x);
	    if (y % 32 < 63) {
		builder.append(",");
	    }

	}
    }

}
